/* cahvor.h */
#ifndef CAHVOR_H
#define CAHVOR_H

#include <stdint.h>
#include "matrix.h"
#include "mex.h"

typedef struct CAHV_MODEL {
    double* C;
    double* A;
    double* H;
    double* V;
    double hs;
    double vs;
    double hc;
    double vc;
    double* Hdash;
    double* Vdash;
} CAHV_MODEL ;

typedef struct CAHVOR_MODEL {
    double* C;
    double* A;
    double* H;
    double* V;
    double* O;
    double* R;
    double hs;
    double vs;
    double hc;
    double vc;
    double* Hdash;
    double* Vdash;
} CAHVOR_MODEL ;

double* mxGetDoublesComponent_CAHVOR_MODEL(const mxArray *pm, char* nameX,
        size_t N, int8_T is_required){
    mxArray *cam_X_mxar, *cam_X_mxard;
    double* X;
    cam_X_mxar = mxGetProperty(pm, 0, nameX);
    if(cam_X_mxar == NULL || mxIsEmpty(cam_X_mxar)){
        if(is_required){
            mexErrMsgIdAndTxt("cahvor:mexGet_CAHVOR_MODEL"," Property (%s) is missing.",nameX);
        } else {
            X = NULL;
        }   
    } else {
        //cam_X_mxard = mxDuplicateArray(cam_X_mxar);
        // X = mxGetDoubles(cam_X_mxard);
        X = mxGetDoubles(cam_X_mxar);
        if(mxGetNumberOfElements(cam_X_mxar) != N){
            mexErrMsgIdAndTxt("cahvor:mexGet_CAHVOR_MODEL","%s does not have a right size.",nameX);
        }
    }
    return X;
}

double mxGetScalarComponent_CAHVOR_MODEL(const mxArray *pm, char* nameX){
    mxArray *cam_X_mxar, *cam_X_mxard;
    double X;
    cam_X_mxar = mxGetProperty(pm, 0, nameX);
    if(cam_X_mxar == NULL || mxIsEmpty(cam_X_mxar)){
        X = 0;
    } else {
        // cam_X_mxard = mxDuplicateArray(cam_X_mxar);
        // X = mxGetScalar(cam_X_mxard);
        X = mxGetScalar(cam_X_mxar);
    }
    return X;
}

CAHVOR_MODEL mxGet_CAHVOR_MODEL(const mxArray *pm){
    CAHVOR_MODEL cahvor_mdl;
    
    if(mxGetNumberOfElements(pm)>1)
        mexErrMsgIdAndTxt("cahvor:mexGet_CAHVOR_MODEL","Input is larger than 1.");

    cahvor_mdl.C = mxGetDoublesComponent_CAHVOR_MODEL(pm,"C",3,1);
    cahvor_mdl.A = mxGetDoublesComponent_CAHVOR_MODEL(pm,"A",3,1);
    cahvor_mdl.H = mxGetDoublesComponent_CAHVOR_MODEL(pm,"H",3,1);
    cahvor_mdl.V = mxGetDoublesComponent_CAHVOR_MODEL(pm,"V",3,1);
    cahvor_mdl.O = mxGetDoublesComponent_CAHVOR_MODEL(pm,"O",3,1);
    cahvor_mdl.R = mxGetDoublesComponent_CAHVOR_MODEL(pm,"R",3,1);
    cahvor_mdl.hs = mxGetScalarComponent_CAHVOR_MODEL(pm,"hs");
    cahvor_mdl.vs = mxGetScalarComponent_CAHVOR_MODEL(pm,"vs");
    cahvor_mdl.hc = mxGetScalarComponent_CAHVOR_MODEL(pm,"hc");
    cahvor_mdl.vc = mxGetScalarComponent_CAHVOR_MODEL(pm,"vc");
    cahvor_mdl.Hdash = mxGetDoublesComponent_CAHVOR_MODEL(pm,"Hdash",3,0);
    cahvor_mdl.Vdash = mxGetDoublesComponent_CAHVOR_MODEL(pm,"Vdash",3,0);

    return cahvor_mdl;
    
}

CAHV_MODEL mxGet_CAHV_MODEL(const mxArray *pm){
    CAHV_MODEL cahv_mdl;
    
    if(mxGetNumberOfElements(pm)>1)
        mexErrMsgIdAndTxt("cahvor:mexGet_CAHVOR_MODEL","Input is larger than 1.");

    cahv_mdl.C = mxGetDoublesComponent_CAHVOR_MODEL(pm,"C",3,1);
    cahv_mdl.A = mxGetDoublesComponent_CAHVOR_MODEL(pm,"A",3,1);
    cahv_mdl.H = mxGetDoublesComponent_CAHVOR_MODEL(pm,"H",3,1);
    cahv_mdl.V = mxGetDoublesComponent_CAHVOR_MODEL(pm,"V",3,1);
    cahv_mdl.hs = mxGetScalarComponent_CAHVOR_MODEL(pm,"hs");
    cahv_mdl.vs = mxGetScalarComponent_CAHVOR_MODEL(pm,"vs");
    cahv_mdl.hc = mxGetScalarComponent_CAHVOR_MODEL(pm,"hc");
    cahv_mdl.vc = mxGetScalarComponent_CAHVOR_MODEL(pm,"vc");
    cahv_mdl.Hdash = mxGetDoublesComponent_CAHVOR_MODEL(pm,"Hdash",3,0);
    cahv_mdl.Vdash = mxGetDoublesComponent_CAHVOR_MODEL(pm,"Vdash",3,0);

    return cahv_mdl;
    
}

#endif