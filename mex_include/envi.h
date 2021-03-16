/* envi.h */
#ifndef ENVI_H
#define ENVI_H

#include <stdint.h>
#include <stdbool.h>
#include <string.h> 
#include "mex.h"
#include "matrix.h"

typedef enum EnviHeaderInterleave {
    BSQ,BIP,BIL
} EnviHeaderInterleave ;

typedef struct EnviHeader {
    int32_T samples;
    int32_T lines;
    int32_T bands;
    int32_T data_type;
    int32_T byte_order;
    int32_T header_offset;
    EnviHeaderInterleave interleave;
    char* file_type;
    double data_ignore_value;
} EnviHeader ;

EnviHeader mxGetEnviHeader(const mxArray *pm){
    EnviHeader msldem_hdr;
    char *interleave_char;
    
    if(mxGetField(pm,0,"samples")!=NULL){
        msldem_hdr.samples = (int32_T) mxGetScalar(mxGetField(pm,0,"samples"));
    }else{
        mexErrMsgIdAndTxt("envi:mexGetEnviHeader","Struct is not an envi header (sample)");
    }
    if(mxGetField(pm,0,"lines")!=NULL){
        msldem_hdr.lines = (int32_T) mxGetScalar(mxGetField(pm,0,"lines"));
    }else{
        mexErrMsgIdAndTxt("envi:mexGetEnviHeader","Struct is not an envi header");
    }
    if(mxGetField(pm,0,"bands")!=NULL){
        msldem_hdr.bands = (int32_T) mxGetScalar(mxGetField(pm,0,"bands"));
    }else{
        mexErrMsgIdAndTxt("envi:mexGetEnviHeader","Struct is not an envi header");
    }
    if(mxGetField(pm,0,"interleave")!=NULL){
        interleave_char = mxArrayToString(mxGetField(pm,0,"interleave"));
        if(strcmp(interleave_char,"bil")==0){
            msldem_hdr.interleave = BIL;
        } else if(strcmp(interleave_char,"bsq")==0) {
            msldem_hdr.interleave = BSQ;
        } else if(strcmp(interleave_char,"bip")==0) {
            msldem_hdr.interleave = BIP;
        } else {
            mexErrMsgIdAndTxt("envi:mexGetEnviHeader","Interleave is not valid");
        }
    }else{
        mexErrMsgIdAndTxt("envi:mexGetEnviHeader","Struct is not an envi header");
    }
    if(mxGetField(pm,0,"data_type")!=NULL){
        msldem_hdr.data_type = (int32_T) mxGetScalar(mxGetField(pm,0,"data_type"));
    }else{
        mexErrMsgIdAndTxt("envi:mexGetEnviHeader","Struct is not an envi header");
    }
    if(mxGetField(pm,0,"byte_order")!=NULL){
        msldem_hdr.byte_order = (int32_T) mxGetScalar(mxGetField(pm,0,"byte_order"));
    }else{
        mexErrMsgIdAndTxt("envi:mexGetEnviHeader","Struct is not an envi header");
    }
    if(mxGetField(pm,0,"header_offset")!=NULL){
        msldem_hdr.header_offset = (int32_T) mxGetScalar(mxGetField(pm,0,"header_offset"));
    }else{
        mexErrMsgIdAndTxt("envi:mexGetEnviHeader","Struct is not an envi header");
    }
    if(mxGetField(pm,0,"data_ignore_value")!=NULL){
        msldem_hdr.data_ignore_value = mxGetScalar(mxGetField(pm,0,"data_ignore_value"));
    }else{
        printf("envi:mexGetEnviHeader data_ignore_value is not defined\n");
        // mexErrMsgIdAndTxt("envi:mexGetEnviHeader","Struct is not an envi header");
    }
    
    mxFree(interleave_char);
    return msldem_hdr;
    
}

bool isComputerLSBF(void){
    int i = 1;
    char *c = (char*)&i;
    
    if (*c) {
        /* little endian */
        return true;
        //printf("Little endian");
    } else {
        /* big endian */
        return false;
        // printf("Big endian");
    }
        
}

/* function : swapFloat_shuffle 
 *  swap the bytes of the input float variable into the reverse direction 
 *  for resolving endian issues using byte shuffling.  
 *  Input Parameters
 *    float inFolat: input float before swapped 
 *  Returns
 *    float retVal : output float after swapped */
float swapFloat_shuffle( float inFloat )
{
   float retVal;
   char *inFloat_char = (char*) &inFloat;
   char *retVal_char  = (char*) &retVal;
   
   // swap the bytes into a temporary buffer
   retVal_char[0] = inFloat_char[3];
   retVal_char[1] = inFloat_char[2];
   retVal_char[2] = inFloat_char[1];
   retVal_char[3] = inFloat_char[0];

   return retVal;
}

/* function : swapFloat 
 *  swap the bytes of the input float variable into the reverse direction 
 *  for resolving endian issues using bit shifts. 
 *  Input Parameters
 *    float inFolat: input float before swapped 
 *  Returns
 *    float retVal : output float after swapped */
float swapFloat( const float inFloat )
{
   float retVal;
   uint32_T *inFloat_int = (uint32_T*) &inFloat;
   uint32_T *retVal_int  = (uint32_T*) &retVal;
   
   *retVal_int = (*inFloat_int<<24) | ( (*inFloat_int<<8) & 0x00FF0000u )
                 | ( (*inFloat_int>>8) & 0x0000FF00u)
                 | ( (*inFloat_int>>24) & 0x000000FFu);
   
   return retVal;
}

#endif