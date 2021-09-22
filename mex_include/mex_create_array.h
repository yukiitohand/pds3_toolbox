/* mex_create_array.h */
#ifndef MEX_CREATE_ARRAY_H
#define MEX_CREATE_ARRAY_H

#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include "mex.h"

double** set_mxDoubleMatrix(const mxArray *pmi){
    mwSize M,N;
    mwIndex j;
    double **pm;
    M = mxGetM(pmi); N = mxGetN(pmi);
    pm = (double **) mxMalloc(N*sizeof(double*));
    if(pm==NULL)
        mexErrMsgIdAndTxt("mex_create_array:set_mxDoubleMatrix","Failed to allocate memory space.");
    pm[0] = mxGetDoubles(pmi);
    for(j=1;j<N;j++){
        pm[j] = pm[j-1]+M;
    }
    return pm;
}

float** set_mxSingleMatrix(const mxArray *pmi){
    mwSize M,N;
    mwIndex j;
    float **pm;
    M = mxGetM(pmi); N = mxGetN(pmi);
    pm = (float **) mxMalloc(N*sizeof(float*));
    if(pm==NULL)
        mexErrMsgIdAndTxt("mex_create_array:set_mxSingleMatrix","Failed to allocate memory space.");
    pm[0] = mxGetSingles(pmi);
    for(j=1;j<N;j++){
        pm[j] = pm[j-1]+M;
    }
    return pm;
}

bool** set_mxLogicalMatrix(const mxArray *pmi){
    mwSize M,N;
    mwIndex j;
    bool **pm;
    M = mxGetM(pmi); N = mxGetN(pmi);
    pm = (bool **) mxMalloc(N*sizeof(bool*));
    if(pm==NULL)
        mexErrMsgIdAndTxt("mex_create_array:set_mxLogicalMatrix","Failed to allocate memory space.");
    pm[0] = mxGetLogicals(pmi);
    for(j=1;j<N;j++){
        pm[j] = pm[j-1]+M;
    }
    return pm;
}

uint8_T** set_mxUint8Matrix(const mxArray *pmi){
    mwSize M,N;
    mwIndex j;
    uint8_T **pm;
    M = mxGetM(pmi); N = mxGetN(pmi);
    pm = (uint8_T **) mxMalloc(N*sizeof(uint8_T*));
    if(pm==NULL)
        mexErrMsgIdAndTxt("mex_create_array:set_mxUint8Matrix","Failed to allocate memory space.");
    pm[0] = mxGetUint8s(pmi);
    for(j=1;j<N;j++){
        pm[j] = pm[j-1]+M;
    }
    return pm;
}

uint16_T** set_mxUint16Matrix(const mxArray *pmi){
    mwSize M,N;
    mwIndex j;
    uint16_T **pm;
    M = mxGetM(pmi); N = mxGetN(pmi);
    pm = (uint16_T **) mxMalloc(N*sizeof(uint16_T*));
    if(pm==NULL)
        mexErrMsgIdAndTxt("mex_create_array:set_mxUint16Matrix","Failed to allocate memory space.");
    pm[0] = mxGetUint16s(pmi);
    for(j=1;j<N;j++){
        pm[j] = pm[j-1]+M;
    }
    return pm;
}

int8_T** set_mxInt8Matrix(const mxArray *pmi){
    mwSize M,N;
    mwIndex j;
    int8_T **pm;
    M = mxGetM(pmi); N = mxGetN(pmi);
    pm = (int8_T **) mxMalloc(N*sizeof(int8_T*));
    if(pm==NULL)
        mexErrMsgIdAndTxt("mex_create_array:set_mxInt8Matrix","Failed to allocate memory space.");
    pm[0] = mxGetInt8s(pmi);
    for(j=1;j<N;j++){
        pm[j] = pm[j-1]+M;
    }
    return pm;
}

int16_T** set_mxInt16Matrix(const mxArray *pmi){
    mwSize M,N;
    mwIndex j;
    int16_T **pm;
    M = mxGetM(pmi); N = mxGetN(pmi);
    pm = (int16_T **) mxMalloc(N*sizeof(int16_T*));
    if(pm==NULL)
        mexErrMsgIdAndTxt("mex_create_array:set_mxInt16Matrix","Failed to allocate memory space.");
    pm[0] = mxGetInt16s(pmi);
    for(j=1;j<N;j++){
        pm[j] = pm[j-1]+M;
    }
    return pm;
}

int32_T** set_mxInt32Matrix(const mxArray *pmi){
    mwSize M,N;
    mwIndex j;
    int32_T **pm;
    M = mxGetM(pmi); N = mxGetN(pmi);
    pm = (int32_T **) mxMalloc(N*sizeof(int32_T*));
    if(pm==NULL)
        mexErrMsgIdAndTxt("mex_create_array:set_mxInt32Matrix","Failed to allocate memory space.");
    pm[0] = mxGetInt32s(pmi);
    for(j=1;j<N;j++){
        pm[j] = pm[j-1]+M;
    }
    return pm;
}

/* create a column oriented MxN matrix accessed by ar2d[n][m] */
void createDoubleMatrix(double ***ar2d, double **ar_base, size_t N, size_t M)
{
    size_t ni;
    
    *ar2d = (double**) malloc(sizeof(double*) * N);
    *ar_base = (double*) malloc(sizeof(double) * N * M);
    (*ar2d)[0] = *ar_base;
    for(ni=1;ni<N;ni++){
        (*ar2d)[ni] = (*ar2d)[ni-1] + M;
    }
}

void createSingleMatrix(float ***ar2d, float **ar_base, size_t N, size_t M)
{
    size_t ni;
    
    *ar2d = (float**) malloc(sizeof(float*) * N);
    *ar_base = (float*) malloc(sizeof(float) * N * M);
    (*ar2d)[0] = *ar_base;
    for(ni=1;ni<N;ni++){
        (*ar2d)[ni] = (*ar2d)[ni-1] + M;
    }
}

void createInt16Matrix(int16_T ***ar2d, int16_T **ar_base, size_t N, size_t M)
{
    size_t ni;
    
    *ar2d = (int16_T**) malloc(sizeof(int16_T*) * N);
    *ar_base = (int16_T*) malloc(sizeof(int16_T) * N * M);
    (*ar2d)[0] = &(*ar_base)[0];
    for(ni=1;ni<N;ni++){
        (*ar2d)[ni] = (*ar2d)[ni-1] + M;
    }
}

/* Int16 Pointer matrix */
int createInt16PMatrix(int16_T ****ar2d, int16_T ***ar_base, size_t N, size_t M)
{
    size_t ni;
    int err=0;
    
    *ar2d = (int16_T***) malloc(sizeof(int16_T**) * N);
    if(*ar2d==NULL){
        err=1;
        return err;
    }
    *ar_base = (int16_T**) malloc(sizeof(int16_T*) * N * M);
    if(*ar_base==NULL){
        err=1;
        free(*ar2d);
        return err;
    }
    (*ar2d)[0] = &(*ar_base)[0];
    for(ni=1;ni<N;ni++){
        (*ar2d)[ni] = (*ar2d)[ni-1] + M;
    }
    
    return err;
    
}

/* create a column oriented MxN matrix accessed by ar2d[n][m] */
void createInt32Matrix(int32_T ***ar2d, int32_T **ar_base, size_t N, size_t M)
{
    size_t ni;
    
    *ar2d = (int32_T**) malloc(sizeof(int32_T*) * N);
    *ar_base = (int32_T*) malloc(sizeof(int32_T) * N * M);
    (*ar2d)[0] = &(*ar_base)[0];
    for(ni=1;ni<N;ni++){
        (*ar2d)[ni] = (*ar2d)[ni-1] + M;
    }
}

/* Int32 Pointer matrix */
void createInt32PMatrix(int32_T ****ar2d, int32_T ***ar_base, size_t N, size_t M)
{
    size_t ni;
    
    *ar2d = (int32_T***) malloc(sizeof(int32_T**) * N);
    *ar_base = (int32_T**) malloc(sizeof(int32_T*) * N * M);
    (*ar2d)[0] = &(*ar_base)[0];
    for(ni=1;ni<N;ni++){
        (*ar2d)[ni] = (*ar2d)[ni-1] + M;
    }
}

void createDoublePMatrix(double ****ar2d, double ***ar_base, size_t N, size_t M)
{
    size_t ni;
    
    *ar2d = (double***) malloc(sizeof(double**) * N);
    *ar_base = (double**) malloc(sizeof(double*) * N * M);
    (*ar2d)[0] = &(*ar_base)[0];
    for(ni=1;ni<N;ni++){
        (*ar2d)[ni] = (*ar2d)[ni-1] + M;
    }
}

/* =====================================================================
 *   MultBand utilities 
 * ===================================================================== */

/* set_mxInt16MatrixMultBand
 * Return ***pm, pointer of pointer of pointer
 */
int16_t*** set_mxInt16MatrixMultBand(const mxArray *pmi){
    mwSize M,N,B;
    mwSize ndim;
    const mwSize *dims;
    mwSize i,j;
    int16_t ***pm;
    
    ndim = mxGetNumberOfDimensions(pmi);
    if(ndim!=3)
        mexErrMsgIdAndTxt("set_mxInt16MatrixMultBand","input mxArray is not 3-dimensional.");
    
    dims = mxGetDimensions(pmi);
    M = dims[0]; N = dims[1]; B = dims[2];
    pm = (int16_t***) mxMalloc(sizeof(int16_t**)*B);
    
    if(pm==NULL){
        mexErrMsgIdAndTxt("set_mxInt16MatrixMultBand","Failed to allocate memory space.");
    } else {
        for(i=0;i<B;i++){
            pm[i] = (int16_t**) mxMalloc(N*sizeof(int16_t*));
            if(pm[i]!=NULL){
                pm[i][0] = mxGetInt16s(pmi)+M*N*i;
                for(j=1;j<N;j++){
                    pm[i][j] = pm[i][j-1]+M;
                }
            }
        }
    }
    
    return pm;
}

#endif