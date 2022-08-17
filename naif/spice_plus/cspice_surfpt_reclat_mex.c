/* =====================================================================
 * cspice_surfpt_reclat_mex.c
 * Perform cspice_surfpt. Support multiple input vectors u
 * 
 * INPUTS:
 * 0 postin:   double* 3-length position vector
 * 1 u     :   double** 3xN-length pointing vector
 * 2 a,b,c :   double scalar
 * 
 * OUTPUTS:
 * 0 radius    :   double* 1xN-length vector
 * 1 longitude :   double* 1xN-length vector
 * 2 latitude  :   double* 1xN-length vector
 *
 * This is a MEX file for MATLAB.
 * ===================================================================== */
#include <stdint.h>
#include "io64.h"
#include "mex.h"
#include "math.h"
#include "matrix.h"
#include <string.h>
#include <stdio.h>

#include <stdlib.h>
#include "mex_create_array.h"
#include "SpiceUsr.h"

/* main computation routine */
void cspice_sufpt_reclat(double *positn, int32_t N, double **u, 
        double a, double b, double c, double *radius, double *longitude, double *latitude)
{
    SpiceInt i;
    SpiceDouble point[3];
    SpiceBoolean found;
    
    // printf("N=%d\n",N);
    for(i=0;i<N;i++){
        // printf("i=%d\n",i);
        surfpt_c( positn, u[i], a, b, c, point, &found);
        // printf("i=%d\n",i);
        reclat_c( point, radius+i, longitude+i, latitude+i);
    }
    
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *positn;
    double **u;
    double a,b,c;
    mwSize N;
    double *radius, *longitude, *latitude;
    

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
    if(nrhs!=5) {
        mexErrMsgIdAndTxt("cspice_surfpt_mex:nrhs","5 inputs required.");
    }
    if(nlhs!=3) {
        mexErrMsgIdAndTxt("cspice_surfpt_mex:nlhs","3 outputs required.");
    }
    
    /* make sure the first input argument is scalar */
    
    if( !mxIsDouble(prhs[0]) ) {
        mexErrMsgIdAndTxt("cspice_surfpt_mex:notDouble","Input 0 needs to be a double array.");
    }
    if( !mxIsDouble(prhs[1]) ) {
        mexErrMsgIdAndTxt("cspice_surfpt_mex:notDouble","Input 1 needs to be a double array.");
    }
    if( !mxIsDouble(prhs[2]) ) {
        mexErrMsgIdAndTxt("cspice_surfpt_mex:notDouble","Input 2 needs to be a double array.");
    }
    if( !mxIsDouble(prhs[3]) ) {
        mexErrMsgIdAndTxt("cspice_surfpt_mex:notDouble","Input 3 needs to be a double array.");
    }
    if( !mxIsDouble(prhs[4]) ) {
        mexErrMsgIdAndTxt("cspice_surfpt_mex:notDouble","Input 4 needs to be a double array.");
    }
    
    
    /* -----------------------------------------------------------------
     * I/O SETUPs
     * ----------------------------------------------------------------- */
    
    /* INPUT 0 positn */
    positn = mxGetDoubles(prhs[0]);
    
    
    /* INPUT 1 u */
    u = set_mxDoubleMatrix(prhs[1]);
    N = mxGetN(prhs[1]);
    // printf("N=%d\n",N);
    
    /* INPUT 2/3/4 */
    a = mxGetScalar(prhs[2]);
    b = mxGetScalar(prhs[3]);
    c = mxGetScalar(prhs[4]);

    /* OUTPUT 0 msldem imFOV */
    plhs[0] = mxCreateDoubleMatrix(1,N,mxREAL);
    radius = mxGetDoubles(plhs[0]);
    
    plhs[1] = mxCreateDoubleMatrix(1,N,mxREAL);
    longitude = mxGetDoubles(plhs[1]);
    
    plhs[2] = mxCreateDoubleMatrix(1,N,mxREAL);
    latitude = mxGetDoubles(plhs[2]);
    // printf("N=%d\n",N);
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    cspice_sufpt_reclat(positn, (int32_t) N, u, a, b, c, radius, longitude, latitude);
    
    /* free memories */
    mxFree(u);
    
}