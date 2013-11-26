// RayTrace_ScreenPos_X_MEX.c
//
// [x_pixels_left,x_pixels_right] = RayTrace_ScreenPos_X(zdist_fromScreen, ipd, viewdist, pix_per_cm, xpos_world)
// 
// Calculate the horizontal screen position (in pixels) of a point distance xpos_world from the visual midline
// and zdist_fromScreen in infront (-ve) or behind (+ve) the screen
// Equation 2 from Howard and Rogers volume 2, p.541
// 
// [INPUT]
// zdist_fromScreen : distance from the screen (cm)
// ipd              : distance between left and right eyes (cm)
// viewdist         : viewing distance from eye to the screen (cm)
// pix_per_cm       : pixels per 1 centimeter
// xpos_world       : x position in the world coordinate
// 
// [OUTPUT]
// x_pixels         : horizontal screen position (INT (pixels))
// 
// [NOTE]
// This function is written to replace RayTrace_ScreenPos_X function
// to make the processing much faster.
// 
// !!! NOTICE !!!
// for speeding up image generation process,
// I will not put codes for nargin checks.
// Please be careful.
//
//
// Created    : "2010-11-09 13:48:37 ban"
// Last Update: "2010-11-09 15:43:24 ban"

// header files
#include <mex.h>
#include <math.h>
#include <stdio.h>

// define alias
typedef unsigned int UINT;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
  
  UINT i; // iterators
  
  // set input variables
  double *prhs_ptr=(double *)mxGetData(prhs[0]);
  
  const int *dims=mxGetDimensions(prhs[0]);
  const UINT dist_rows=dims[0], dist_cols=dims[1];
  
  const double ipd=(double)mxGetScalar(prhs[1]);
  const double viewdist=(double)mxGetScalar(prhs[2]);
  const double pix_per_cm=(double)mxGetScalar(prhs[3]);
  const int xpos_world=(int)mxGetScalar(prhs[4]);

  // initialize output variable
  plhs[0]=mxCreateDoubleMatrix(dist_rows,dist_cols,mxREAL);
  plhs[1]=mxCreateDoubleMatrix(dist_rows,dist_cols,mxREAL);
  double *plhs0_ptr=(double *)mxGetData(plhs[0]);
  double *plhs1_ptr=(double *)mxGetData(plhs[1]);
  
  for(i=0;i<dist_rows*dist_cols;i++){
    
    if(*(prhs_ptr+i)!=0){
      // for left-eye shift
      *(plhs0_ptr+i) = floor( pix_per_cm * (xpos_world*viewdist + (-1)*(*(prhs_ptr+i))*ipd/2.0) / (viewdist+(*(prhs_ptr+i))) + 0.5);
      // for right-eye shift
      *(plhs1_ptr+i) = floor( pix_per_cm * (xpos_world*viewdist + (+1)*(*(prhs_ptr+i))*ipd/2.0) / (viewdist+(*(prhs_ptr+i))) + 0.5);
    }
    
  }

  return;
}
