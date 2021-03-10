/* =====================================================================
 * get_imFOVmask_MSLDEM_v2_mex.c
 * Evaluate if pixels in the MSL DEM image are potentially in 
 * 
 * INPUTS:
 * 0 msldem_imgpath        char*
 * 1 msldem_header         struct
 * 2 msldem_northing      Double array [L_dem]
 * 3 msldem_easting       Double array [S_dem]
 * 4 S_im                 int
 * 5 L_im                 int
 * 6 cammdl               CAHVOR model class
 * 7 coef_mrgn            coefficient for the margin
 * 
 * 
 * OUTPUTS:
 * 0 msldemc_imFOVmaskd    int8 [L_dem x S_dem]
 * // 1 msldemc_imFOVmaskd    Boolean [L_dem x S_dem]
 * 
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
double f(double rho0,double rho1,double rho2, double x,double c){
    double v;
    double x2;
    x2 = x*x;
    v = ((1+rho0) + rho1*x2 + rho2*x2*x2)*x - c;
    return v;
}


void get_lambda_bisection(size_t N, double *klam, double *cahvor_R, double *lam)
{
    double rho0,rho1,rho2;
    double xl,xr,xm;
    double vl,vr,vm; // value of left, right, and middle
    double tol;
    double c;
    size_t n;
    size_t cnt;
    
   
    
    
    tol = 1e-12;
    
    rho0 = cahvor_R[0]; rho1 = cahvor_R[1]; rho2 = cahvor_R[2];

    for(n=0;n<N;n++){
        // printf("n=%d\n",n);
        c = klam[n];
        xl = 0.0;
        xr = 0.5;
        vl = f(rho0,rho1,rho2,xl,c);
        vr = f(rho0,rho1,rho2,xr,c);
        if(vl<0 && vr>0){
            cnt = 0;
            while((xr-xl)>tol && cnt<64){
                // printf("%e\n",(xr-xl));
                xm = 0.5*(xl+xr);
                vm = f(rho0,rho1,rho2,xm,c);
                if(vm<0){
                    xl = xm; vl = vm;
                } else if(vm>0){
                    xr = xm; vr = vm;
                }
                cnt++;
            }
            lam[n] = xm;
        } else if(vl>0 && vr<0){
            cnt = 0;
            while((xr-xl)>tol && cnt<64){
                // printf("%e\n",(xr-xl));
                xm = 0.5*(xl+xr);
                vm = f(rho0,rho1,rho2,xm,c);
                if(vm>0){
                    xl = xm; vl = vm;
                } else if(vm<0){
                    xr = xm; vr = vm;
                }
                cnt++;
            }
            lam[n] = xm;
            printf("something wrong with n=%d\n",n);
        }
    }
}

/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    double *klam;
    double *cahvor_R;
    double *lam;
    size_t N,i;
    mwSize ndims;
    const mwSize *dims;

    /* -----------------------------------------------------------------
     * CHECK PROPER NUMBER OF INPUTS AND OUTPUTS
     * ----------------------------------------------------------------- */
    /* if(nrhs!=11) {
        mexErrMsgIdAndTxt("proj_mastcam2MSLDEM_v4_mex:nrhs","Eleven inputs required.");
    }
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("proj_mastcam2MSLDEM_v4_mex:nlhs","Five outputs required.");
    }
    */
    /* make sure the first input argument is scalar */
    /*
    if( !mxIsChar(prhs[0]) ) {
        mexErrMsgIdAndTxt("proj_mastcam2MSLDEM_v4_mex:notChar","Input 0 needs to be a character vector.");
    }
    */
    /* -----------------------------------------------------------------
     * I/O SETUPs
     * ----------------------------------------------------------------- */
    
    /* INPUT 0: (1+mu)*lambda */
    klam = mxGetDoubles(prhs[0]);
    N = mxGetNumberOfElements(prhs[0]);
    ndims = mxGetNumberOfDimensions(prhs[0]);
    dims = mxGetDimensions(prhs[0]);
    
    /* INPUT 1: R (Radius) of CAHVOR model */
    cahvor_R = mxGetDoubles(prhs[1]);
    
    
    
    /* OUTPUT 0: lambda */
    plhs[0] = mxCreateNumericArray(ndims, dims ,mxDOUBLE_CLASS,mxREAL);
    lam = mxGetDoubles(plhs[0]);
    
    // Initialize matrices
    for(i=0;i<N;i++){
        lam[i] = NAN;
    }
    // printf("sim = %d\n",S_im);
    /* -----------------------------------------------------------------
     * CALL MAIN COMPUTATION ROUTINE
     * ----------------------------------------------------------------- */
    get_lambda_bisection(N,klam,cahvor_R,lam);
    
    /* free memories */
    
}
