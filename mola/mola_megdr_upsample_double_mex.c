/* =====================================================================
 * mola_megdr_upsampel_double_mex.c
 * Read the specified rectangle region of the MOLA MEGDR image data. The 
 * rectangle part of the image:
 * MOLAMEGDR[smpl_offset:smpl_offset+samples,
 *           line_offset:line_offset+lines]
 * is read.
 * 
 * INPUTS:
 * 0 imgpath       char*
 * 1 header        struct
 * 2 smpl_offset   integer
 * 3 line_offset   integer
 * 4 samples       integer
 * 5 lines         integer
 * 
 * 
 * OUTPUTS:
 * 0  dem_img [S_demc x L_demc]   Float
 * #Note that the image needs to be flipped after this.
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
        double **megdr_img, int32_T megdr_samples, int32_T megdr_lines,
        double megdr_lat0, double megdr_lon0, double megdr_dang,
        double **megdr_u_img, int32_T megdr_u_samples, int32_T megdr_u_lines,
        double megdr_u_lat0, double megdr_u_lon0, double megdr_u_dang)
{
    int32_T c,l;
    int32_T *xlist, *ylist;
    double v_dbl;
    double y0_lat, y0_lon, ar;
    
    
    y0_lat = -(megdr_u_lat0 - megdr_lat0) / megdr_dang;
    y0_lon = (megdr_u_lon0 - megdr_lon0) / megdr_dang;
    ar = megdr_u_dang/megdr_dang;
    
    // printf("%f,%f,%f\n",megdr_u_lat0,megdr_lat0,y0_lat);
    
    xlist = (int32_T*) malloc(sizeof(int32_T)* (size_t) megdr_u_samples);
    ylist = (int32_T*) malloc(sizeof(int32_T)* (size_t) megdr_u_lines);
    
    for(c=0;c<megdr_u_samples;c++){
        // printf("c=%d\n",c);
        v_dbl = ( ar * (double) c ) + y0_lon + 0.5;
        xlist[c] = (int32_T) floor(v_dbl);
        //printf("c=%d,%d\n",c,xlist[c]);
    }
    // printf("a\n");
    
    for(l=0;l<megdr_u_lines;l++){
        // printf("l=%d\n",l);
        v_dbl = ( ar * (double) l ) + y0_lat + 0.5;
        ylist[l] = (int32_T) floor(v_dbl);
        //printf("l=%d,%d\n",l,ylist[l]);
    }
    // printf("a\n");
    
    // printf("%d,%d,%d\n",skip_l,msldemc_samples*s,skip_r);
    for(c=0;c<megdr_u_samples;c++){
        for(l=0;l<megdr_u_lines;l++){
            megdr_u_img[c][l] = megdr_img[xlist[c]][ylist[l]];
        }
    }
    
    free(xlist);
    free(ylist);
    
}



/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double **megdr_img;
    mwSize megdr_samples, megdr_lines;
    double megdr_lat0, megdr_lon0, megdr_dang; 
    mwSize megdr_u_samples, megdr_u_lines;
    double megdr_u_lat0, megdr_u_lon0, megdr_u_dang;
    
    double **megdr_u_img; /* upsample image pointer */
    
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
    megdr_img     = set_mxDoubleMatrix(prhs[0]);
    megdr_lines   = mxGetM(prhs[0]);
    megdr_samples = mxGetN(prhs[0]);
    
    megdr_lat0 = mxGetScalar(prhs[1]);
    megdr_lon0 = mxGetScalar(prhs[2]);
    megdr_dang = mxGetScalar(prhs[3]);
    
    megdr_u_samples = (mwSize) mxGetScalar(prhs[4]);
    megdr_u_lines   = (mwSize) mxGetScalar(prhs[5]);
    
    megdr_u_lat0 = mxGetScalar(prhs[6]);
    megdr_u_lon0 = mxGetScalar(prhs[7]);
    megdr_u_dang = mxGetScalar(prhs[8]);
    
            
    
    plhs[0] = mxCreateDoubleMatrix(megdr_u_lines,megdr_u_samples,mxREAL);
    megdr_u_img = set_mxDoubleMatrix(plhs[0]);
    
    /* Initialization of the output */
    for(c=0;c<megdr_u_samples;c++){
        for(l=0;l<megdr_u_lines;l++){
            megdr_u_img[c][l] = NAN;
        }
    }
    
    // printf("a\n");

    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    megdr_upsample_wmsldem(
            megdr_img, (int32_T) megdr_samples, (int32_T) megdr_lines,
            megdr_lat0, megdr_lon0, megdr_dang,
            megdr_u_img, (int32_T) megdr_u_samples, (int32_T) megdr_u_lines,
            megdr_u_lat0, megdr_u_lon0, megdr_u_dang);
    
    
    /* free memories */
    mxFree(megdr_img);
    mxFree(megdr_u_img);
    
    
}
