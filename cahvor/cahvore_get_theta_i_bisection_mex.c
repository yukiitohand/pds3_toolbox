/* =====================================================================
 * cahvore_get_theta_i_bisection_mex.c
 * Get the angle 
 * 
 * INPUTS:
 * 0 zeta      : Double array [N]
 * 1 lam       : Double array [N]
 * 2 cahvore_e : Double array [3]
 * 
 * OUTPUTS:
 * 0 theta Double array [N]
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
#include "envi.h"
#include "mex_create_array.h"

/* main computation routine */
double f(double ep0, double ep1,double ep2, double zeta, double lam, double theta){
    double v;
    double theta2;
    theta2 = theta*theta;
    v = zeta * sin(theta) - lam * cos(theta) - (theta-sin(theta))*(ep0+ep1*theta2+ep2*theta2*theta2);
    return v;
}


void cahvore_get_theta_i_bisection(size_t N, double *zeta, double *lam, double *cahvore_E, double *theta)
{
    double ep0,ep1,ep2;
    double xl,xr,xm;
    double vl,vr,vm; // value of left, right, and middle
    double tol;
    size_t n;
    size_t cnt;
    

    tol = 1e-12;
    
    ep0 = cahvore_E[0]; ep1 = cahvore_E[1]; ep2 = cahvore_E[2];

    for(n=0;n<N;n++){
        // printf("n=%d\n",n);
        xl = 0.0;
        xr = M_PI;
        vl = f(ep0,ep1,ep2,zeta[n],lam[n],xl);
        vr = f(ep0,ep1,ep2,zeta[n],lam[n],xr);
        if(vl<0 && vr>0){
            cnt = 0;
            while((xr-xl)>tol && cnt<64){
                // printf("%e\n",(xr-xl));
                xm = 0.5*(xl+xr);
                vm = f(ep0,ep1,ep2,zeta[n],lam[n],xm);
                if(vm<0){
                    xl = xm; vl = vm;
                } else if(vm>0){
                    xr = xm; vr = vm;
                }
                cnt++;
            }
            theta[n] = xm;
        } else if(vl>0 && vr<0){
            cnt = 0;
            while((xr-xl)>tol && cnt<64){
                // printf("%e\n",(xr-xl));
                xm = 0.5*(xl+xr);
                vm = f(ep0,ep1,ep2,zeta[n],lam[n],xm);
                if(vm>0){
                    xl = xm; vl = vm;
                } else if(vm<0){
                    xr = xm; vr = vm;
                }
                cnt++;
            }
            theta[n] = xm;
            printf("something wrong with n=%d\n",n);
        }
    }
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *zeta;
    double *lam;
    double *cahvore_E;
    double *theta;
    size_t N,i;
    mwSize ndims;
    const mwSize *dims;

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
    if(nrhs!=3) {
        mexErrMsgIdAndTxt("cahvore_get_theta_i_bisection_mex:nrhs","Three inputs are required.");
    }
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("cahvore_get_theta_i_bisection_mex:nlhs","One input is required.");
    }
    
    /* make sure the first input argument is scalar */
    /*
    if( !mxIsChar(prhs[0]) ) {
        mexErrMsgIdAndTxt("proj_mastcam2MSLDEM_v4_mex:notChar","Input 0 needs to be a character vector.");
    }
    */
    /* -----------------------------------------------------------------
     * I/O SETUPs
     * ----------------------------------------------------------------- */
    
    /* INPUT 0: zeta */
    zeta = mxGetDoubles(prhs[0]);
    N = mxGetNumberOfElements(prhs[0]);
    ndims = mxGetNumberOfDimensions(prhs[0]);
    dims = mxGetDimensions(prhs[0]);

    lam = mxGetDoubles(prhs[1]);
    
    /* INPUT 1: R (Radius) of CAHVOR model */
    cahvore_E = mxGetDoubles(prhs[2]);
    
    
    
    /* OUTPUT 0: lambda */
    plhs[0] = mxCreateNumericArray(ndims, dims ,mxDOUBLE_CLASS,mxREAL);
    theta = mxGetDoubles(plhs[0]);
    
    // Initialize matrices
    for(i=0;i<N;i++){
        theta[i] = NAN;
    }
    // printf("sim = %d\n",S_im);
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    cahvore_get_theta_i_bisection(N, zeta, lam, cahvore_E, theta);
    
    /* free memories */
    
}
