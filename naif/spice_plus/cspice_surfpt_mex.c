/* =====================================================================
 * cspice_surfpt_mex.c
 * Perform cspice_surfpt. Support multiple input vectors u
 * 
 * INPUTS:
 * 0 postin:   double* 3-length position vector
 * 1 u     :   double** 3xN-length pointing vector
 * 2 a,b,c :   double scalar
 * 
 * OUTPUTS:
 * 0 point     :   double** 3xN-length pointing vector
 * 1 found     :   int *N length found vector
 *
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
void cspice_sufptx(double *positn, int32_t N, double **u, 
        double a, double b, double c, double **point, int *found)
{
    SpiceInt i;
    
    for(i=0;i<N;i++){
        surfpt_c ( positn, u[i], a, b, c, point[i], found+i); 
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
    double **point;
    int *found;
    

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
    if(nrhs!=5) {
        mexErrMsgIdAndTxt("cspice_surfpt_mex:nrhs","5 inputs required.");
    }
    if(nlhs!=2) {
        mexErrMsgIdAndTxt("cspice_surfpt_mex:nlhs","2 outputs required.");
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
    plhs[0] = mxCreateDoubleMatrix(3,N,mxREAL);
    point = set_mxDoubleMatrix(plhs[0]);
    
    plhs[1] = mxCreateNumericMatrix(1,N,mxINT32_CLASS,mxREAL);
    found = mxGetInt32s(plhs[1]);
    
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    cspice_sufptx(positn, (int32_t) N, u, a, b, c, point, found);
    
    /* free memories */
    mxFree(u);
    mxFree(point);
    
}