/* =====================================================================
 * hirise_lazyenvireadRect_mex.c
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
#include "matrix.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "envi.h"
#include "mex_create_array.h"


/* main computation routine */
void lazyenvireadRectInt16(char *imgpath, EnviHeader hdr, 
        size_t smpl_offset, size_t line_offset,
        float **img, size_t samples, size_t lines)
{
    size_t i,j;
    long int skip_pri;
    long int skip_l, skip_r;
    float *buf;
    size_t s=sizeof(float);
    FILE *fid;
    size_t ncpy;
    int16_T swapped;
    
    
    fid = fopen(imgpath,"rb");
    
    /* skip lines */
    skip_pri = (long int) hdr.samples * (long int) line_offset * (long int) s;
    fseek(fid,skip_pri,SEEK_CUR);
    
    /* read the data */
    ncpy = samples * s;
    buf = (float*) malloc(ncpy);
    skip_l = (long int) s * (long int) smpl_offset;
    skip_r = ((long int) hdr.samples - (long int) samples) * (long int) s - skip_l;
    
    // printf("%d,%d,%d\n",skip_l,msldemc_samples*s,skip_r);
    for(i=0;i<lines;i++){
        //printf("%d/%d\n",i,msldemc_lines);
        fseek(fid,skip_l,SEEK_CUR);
        fread(buf,s,samples,fid);
        memcpy(img[i],buf,ncpy);
        fseek(fid,skip_r,SEEK_CUR);
        //_fseeki64(fp,skips,SEEK_CUR);
    }
    free(buf);
    fclose(fid);
}



/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    char *imgpath;
    EnviHeader hdr;
    double smpl_offset_dbl,line_offset_dbl;
    mwSize smpl_offset,line_offset;
    float **img;
    double samples_dbl, lines_dbl;
    mwSize samples, lines;
    // mwSize j;

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
    if(nrhs!=6) {
        mexErrMsgIdAndTxt("hirise_lazyenvireadRect_mex:nrhs","Six inputs required.");
    }
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("hirise_lazyenvireadRect_mex:nlhs","Five outputs required.");
    }
    /* make sure the first input argument is scalar */
    if( !mxIsChar(prhs[0]) ) {
        mexErrMsgIdAndTxt("hirise_lazyenvireadRect_mex:notChar","Input 0 needs to be a string.");
    }
    if( !mxIsStruct(prhs[1]) ) {
        mexErrMsgIdAndTxt("hirise_lazyenvireadRect_mex:notStruct","Input 1 needs to be a struct.");
    }
    if( !mxIsScalar(prhs[2]) ) {
        mexErrMsgIdAndTxt("hirise_lazyenvireadRect_mex:notScalar","Input 2 needs to be a scalar.");
    }
    if( !mxIsScalar(prhs[3]) ) {
        mexErrMsgIdAndTxt("hirise_lazyenvireadRect_mex:notScalar","Input 3 needs to be a scalar.");
    }
    if( !mxIsScalar(prhs[4]) ) {
        mexErrMsgIdAndTxt("hirise_lazyenvireadRect_mex:notScalar","Input 4 needs to be a scalar.");
    }
    if( !mxIsScalar(prhs[5]) ) {
        mexErrMsgIdAndTxt("hirise_lazyenvireadRect_mex:notScalar","Input 5 needs to be a scalar.");
    }
    
    /* -----------------------------------------------------------------
     * I/O SETUPs
     * ----------------------------------------------------------------- */
    
    /* INPUT 0 msldem_imgpath */
    imgpath = mxArrayToString(prhs[0]);
    //printf("%s\n",msldem_imgpath);
    
    /* INPUT 1 msldem_header */
    hdr = mxGetEnviHeader(prhs[1]);

    // printf("%d\n",msldem_header.samples);
    /* INPUT 2/3 msldemc_sample_offset */
    smpl_offset_dbl = mxGetScalar(prhs[2]);
    if(smpl_offset_dbl>-1e-10)
        smpl_offset = (mwSize) smpl_offset_dbl;
    else
        mexErrMsgIdAndTxt("hirise_lazyenvireadRect_mex:notnonnegative","Input 2 needs to be a nonnegative.");
    
    line_offset_dbl = mxGetScalar(prhs[3]);
    if(line_offset_dbl>-1e-10)
        line_offset = (mwSize) line_offset_dbl;
    else
        mexErrMsgIdAndTxt("hirise_lazyenvireadRect_mex:notnonnegative","Input 3 needs to be a nonnegative.");
    
    /* INPUT 4/5 msldem rectangle size */
    samples_dbl = mxGetScalar(prhs[4]);
    if(samples_dbl>-1e-10)
        samples = (mwSize) samples_dbl;
    else
        mexErrMsgIdAndTxt("hirise_lazyenvireadRect_mex:notnonnegative","Input 4 needs to be a nonnegative.");
    
    lines_dbl = mxGetScalar(prhs[5]);
    if(lines_dbl>-1e-10)
        lines = (mwSize) lines_dbl;
    else
        mexErrMsgIdAndTxt("hirise_lazyenvireadRect_mex:notnonnegative","Input 5 needs to be a nonnegative.");
    
    plhs[0] = mxCreateNumericMatrix(samples,lines,mxSINGLE_CLASS,mxREAL);
    img = set_mxSingleMatrix(plhs[0]);
    
    // printf("%d,%d,%d,%d\n",smpl_offset,samples,line_offset,lines);
    
    // dem_img = (float **) mxMalloc(msldemc_lines * sizeof(*dem_img) );
    // dem_img[0] = mxGetSingles(plhs[0]);
    // for( j=1;j<msldemc_lines;j++){
    //     dem_img[j] = dem_img[j-1] + msldemc_samples;
    // }

    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    lazyenvireadRectInt16(imgpath,hdr,(size_t) smpl_offset, 
            (size_t) line_offset, img, (size_t) samples, (size_t) lines);
    
    /* free memories */
    mxFree(imgpath);
    mxFree(img);
    
    
}
