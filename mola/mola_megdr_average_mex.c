/* =====================================================================
 * mola_megdr_average_mex.c
 * Perform averaging on the upsampled mola image.
 * 
 * INPUTS:
 * 0 imgA          [megdr_img_u_lines x megdr_img_u_samples] int16 upsampled mola image
 * 1 msldem_sample_offset integer sample offset for the msl image
 * 2 msldem_line_offset   integer line offset for the msl image
 * 3 msldem_samples       integer number of samples for the msldem image
 * 4 msldem_lines         integer number of lines for the msldem image
 * 5 wng_sz               integer size of the wing (2*wng_sz+1) would be 
 *                                the window size.
 * 
 * 
 * OUTPUTS:
 * 0  megdr_ua_img [megdr_lines x megdr_samples], double,
 *       upsampled mola image 
 *
 *
 * This is a MEX file for MATLAB.
 * ===================================================================== */
#include "io64.h"
#include "mex.h"
#include "math.h"
#include "matrix.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "envi.h"
#include "mex_create_array.h"


/* main computation routine */
void megdr_upsample_wmsldem(
        int16_T **megdr_u_img, int32_T megdr_u_samples, int32_T megdr_u_lines,
        double **megdr_ua_img,
        int32_T msldem_sample_offset, int32_T msldem_line_offset,
        int32_T msldem_samples, int32_T msldem_lines,
        int32_T wng_sz)
{
    int32_T c,l;
    double **img_cumsum,*img_cumsum_base;
    double wndw_Nelem;
    int32_T c1,c2,l1,l2;
    
    createDoubleMatrix(&img_cumsum, &img_cumsum_base, (size_t) megdr_u_samples, (size_t) megdr_u_lines);
    for(c=0;c<megdr_u_samples;c++){
        for(l=0;l<megdr_u_lines;l++){
            img_cumsum[c][l] = 0;
        }
    }
    printf("a\n");
    img_cumsum[0][0] = (double) megdr_u_img[0][0];
    for(c=1;c<megdr_u_samples;c++)
        img_cumsum[c][0] = img_cumsum[c-1][0] + (double) megdr_u_img[c][0];
    for(l=1;l<megdr_u_lines;l++)
        img_cumsum[0][l] = img_cumsum[0][l-1] + (double) megdr_u_img[0][l];
    for(c=1;c<megdr_u_samples;c++){
        for(l=1;l<megdr_u_lines;l++){
            img_cumsum[c][l] = img_cumsum[c-1][l] + img_cumsum[c][l-1] - img_cumsum[c-1][l-1] + (double) megdr_u_img[c][l];
        }
    }
    printf("a\n");
    
    // printf("%d,%d,%d\n",skip_l,msldemc_samples*s,skip_r);
    wndw_Nelem = (2* (double) wng_sz+1)*(2* (double) wng_sz+1);
    for(c=0;c<msldem_samples;c++){
        c1 = c - wng_sz + msldem_sample_offset-1;
        c2 = c + wng_sz + msldem_sample_offset;
        for(l=0;l<msldem_lines;l++){
            l1 = l - wng_sz + msldem_line_offset-1;
            l2 = l + wng_sz + msldem_line_offset;
            
            megdr_ua_img[c][l] = (img_cumsum[c2][l2] - img_cumsum[c1][l2] - img_cumsum[c2][l1] + img_cumsum[c1][l1])/wndw_Nelem;
        }
    }
    
    free(img_cumsum);
    free(img_cumsum_base);
    
    
}



/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    int16_T **megdr_u_img;
    mwSize megdr_u_samples, megdr_u_lines;
    
    double **megdr_ua_img; /* upsample image pointer */
    
    mwSize msldem_sample_offset, msldem_line_offset;
    mwSize msldem_samples, msldem_lines;
    
    mwSize wng_sz;
    
    mwSize c,l;

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
//     if(nrhs!=6) {
//         mexErrMsgIdAndTxt("mola_megdr_lazyenvireadRectInt16_mex:nrhs","Six inputs required.");
//     }
//     if(nlhs!=1) {
//         mexErrMsgIdAndTxt("mola_megdr_lazyenvireadRectInt16_mex:nlhs","Five outputs required.");
//     }
//     /* make sure the first input argument is scalar */
//     if( !mxIsChar(prhs[0]) ) {
//         mexErrMsgIdAndTxt("mola_megdr_lazyenvireadRectInt16_mexx:notChar","Input 0 needs to be a string.");
//     }
//     if( !mxIsStruct(prhs[1]) ) {
//         mexErrMsgIdAndTxt("mola_megdr_lazyenvireadRectInt16_mexx:notStruct","Input 1 needs to be a struct.");
//     }
//     if( !mxIsScalar(prhs[2]) ) {
//         mexErrMsgIdAndTxt("mola_megdr_lazyenvireadRectInt16_mex:notScalar","Input 2 needs to be a scalar.");
//     }
//     if( !mxIsScalar(prhs[3]) ) {
//         mexErrMsgIdAndTxt("mola_megdr_lazyenvireadRectInt16_mex:notScalar","Input 3 needs to be a scalar.");
//     }
//     if( !mxIsScalar(prhs[4]) ) {
//         mexErrMsgIdAndTxt("mola_megdr_lazyenvireadRectInt16_mex:notScalar","Input 4 needs to be a scalar.");
//     }
//     if( !mxIsScalar(prhs[5]) ) {
//         mexErrMsgIdAndTxt("mola_megdr_lazyenvireadRectInt16_mex:notScalar","Input 5 needs to be a scalar.");
//     }
    
    /* -----------------------------------------------------------------
     * I/O SETUPs
     * ----------------------------------------------------------------- */
    
    /* INPUT 0:  */
    megdr_u_img     = set_mxInt16Matrix(prhs[0]);
    megdr_u_lines   = mxGetM(prhs[0]);
    megdr_u_samples = mxGetN(prhs[0]);
    
    msldem_sample_offset = (mwSize) mxGetScalar(prhs[1]);
    msldem_line_offset   = (mwSize) mxGetScalar(prhs[2]);
    msldem_samples       = (mwSize) mxGetScalar(prhs[3]);
    msldem_lines         = (mwSize) mxGetScalar(prhs[4]);
    
    wng_sz = (mwSize) mxGetScalar(prhs[5]);
            
    
    plhs[0] = mxCreateDoubleMatrix(msldem_lines,msldem_samples,mxREAL);
    megdr_ua_img = set_mxDoubleMatrix(plhs[0]);
    
    /* Initialization of the output */
    for(c=0;c<msldem_samples;c++){
        for(l=0;l<msldem_lines;l++){
            megdr_ua_img[c][l] = NAN;
        }
    }
    
    printf("a\n");

    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    megdr_upsample_wmsldem(
            megdr_u_img, (int32_T) megdr_u_samples, (int32_T) megdr_u_lines,
            megdr_ua_img,
            (int32_T) msldem_sample_offset, (int32_T) msldem_line_offset,
            (int32_T) msldem_samples, (int32_T) msldem_lines,
            (int32_T) wng_sz);
    
    
    /* free memories */
    mxFree(megdr_u_img);
    mxFree(megdr_ua_img);
    
    
}
