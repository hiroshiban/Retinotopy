// ReplaceDots2Ovals_with_noise.cpp
// 
// img=ReplaceDots2Ovals_with_noise(img,noise_img,dot_pos_idx,noise_dot_num,wdot,bdot,dotalpha,bgcolor,LR_flag)
// 
// MEX function used in "RDSfastest_with_noise_MEX" function
//
// Generate left/right Random Dot Stereogram (RDS) Image with gaussian
// filtered white/black dots
//
// [NOTE]
// This function is written to replace parts of MATLAB subroutines
// in sla_RDSfastest_with_noise function to make the processing
// much faster. Actually, it makes the processing 3 times faster
// compared with purely MATLAB subroutines.
// 
// [input]
// img           : base image with background color and dot IDs
// noise_img     : flag map to decide whether the dot is noise(anticorrelated)
//                 or signal(correlated)
// dot_pos_idx   : indexes of dot positions
// noise_dot_num : number of dots used for noise in the RDS image
// wdot          : oval 1 to be used in RDS image
// bdot          : oval 2 to be used in RDS image
// dotalpha      : alpha value of oval 1&2 [row,col] (same size with wdot & bdot)
// bgcolor       : background color, [0-255]
// LR_flag       : whether the image is for left eye or right eye (1=left,0=right)
// 
// [output]
// img           : generated image
// 
// 
// !!! NOTICE !!!
// for speeding up image generation process,
// I will not put codes for nargin checks.
// Please be careful.
//
//
// Created:     "2010-11-07 13:28:28 ban"
// Last Update: "2010-12-03 17:52:37 ban"

// header files
#include <mex.h>
#include <math.h>
#include <stdio.h>

// define min() & max() macros
#ifndef max
#define max(a,b) (((a) > (b)) ? (a) : (b))
#endif
#ifndef min
#define min(a,b) (((a) < (b)) ? (a) : (b))
#endif

// define alias
typedef unsigned int UINT;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
  
  UINT i,j,k; // iterators
  
  // get the size of input image
  const int *dims=mxGetDimensions(prhs[0]);
  const UINT img_rows=dims[0], img_cols=dims[1];

  const int num_of_dims=mxGetNumberOfDimensions(prhs[0]);
  int dim = 1; // Number of colors (default - gray scale)
  if(num_of_dims==3) dim=dims[2];
  
  // get the size of dot position matrix
  UINT num_pos_dots=mxGetM(prhs[2]);
  
  // get the number of noise dots
  UINT num_noise=(UINT)mxGetScalar(prhs[3]);
  
  // get the size of white/black dots
  const int
      wdot_rows=mxGetM(prhs[4]), wdot_cols=mxGetN(prhs[4]),
      bdot_rows=mxGetM(prhs[5]), bdot_cols=mxGetN(prhs[5]);
  
  // get alpha value
  double *alpha_vals=(double *)mxGetData(prhs[6]);

  // get background color
  UINT bgcolor=(UINT)mxGetScalar(prhs[7]);
  
  // get left/right flag
  UINT left_flag=(UINT)mxGetScalar(prhs[8]);

  // allocate memory for output left/right RDS images
  plhs[0]=mxCreateNumericArray(num_of_dims,dims,mxUINT32_CLASS,mxREAL);
  UINT *plhs_ptr=(UINT *)mxGetData(plhs[0]);
  // initializing
  for(i=0;i<img_cols;i++){
    for(j=0;j<img_rows;j++){
      *(plhs_ptr+j+i*img_rows)=bgcolor;
    }
  }
  
  // get pointers to input image, wdot, and bdot
  UINT *img_ptr=(UINT *)mxGetPr(prhs[0]);
  UINT *noise_ptr=(UINT *)mxGetPr(prhs[1]);
  double *pos_ptr=mxGetPr(prhs[2]);
  double *wdot_ptr=mxGetPr(prhs[4]);
  double *bdot_ptr=mxGetPr(prhs[5]);
  
  // declare pointer & variables to treat dot
  double *dot_ptr;
  UINT dot_rows, dot_cols;
  UINT tmp_row_limit, tmp_col_limit;
  UINT img_pos, dot_pos;
  
  UINT img_idx_row_min, img_idx_row_max, img_idx_col_min, img_idx_col_max;
  UINT dot_idx_row_min, dot_idx_row_max, dot_idx_col_min, dot_idx_col_max;

  UINT crow,ccol; // store the current row & col
  
  // replace dots to ovals
  int noise_ndone=0;
  for(i=0;i<num_pos_dots;i++){
    
    // select dots (white or black)
    if( *( noise_ptr + (UINT)(*(pos_ptr+i)-1) ) != 0 ){
      if(noise_ndone++ < num_noise){
        if( *( img_ptr + (UINT)(*(pos_ptr+i)-1) )%2 != 0 ){
          if(left_flag){ dot_ptr=wdot_ptr; dot_rows=wdot_rows; dot_cols=wdot_cols; }
          else{ dot_ptr=bdot_ptr; dot_rows=bdot_rows; dot_cols=bdot_cols; }
        }else{
          if(left_flag){ dot_ptr=bdot_ptr; dot_rows=bdot_rows; dot_cols=bdot_cols; }
          else{ dot_ptr=wdot_ptr; dot_rows=wdot_rows; dot_cols=wdot_cols; }
        }
      }else{
        if( *( img_ptr + (UINT)(*(pos_ptr+i)-1) )%2 != 0 ){ dot_ptr=bdot_ptr; dot_rows=bdot_rows; dot_cols=bdot_cols; }
        else{ dot_ptr=wdot_ptr; dot_rows=wdot_rows; dot_cols=wdot_cols; }
      }
    }else{
      if( *( img_ptr + (UINT)(*(pos_ptr+i)-1) )%2 != 0 ){ dot_ptr=bdot_ptr; dot_rows=bdot_rows; dot_cols=bdot_cols; }
      else{ dot_ptr=wdot_ptr; dot_rows=wdot_rows; dot_cols=wdot_cols; }
    }
    
    // set row/col borders
    tmp_row_limit=(UINT)floor((double)dot_rows+0.5)/2;
    tmp_col_limit=(UINT)floor((double)dot_cols+0.5)/2;
    
    // get the current row & col in img
    crow=(UINT)*(pos_ptr+i)%img_rows;
    if(crow==0) crow=img_rows;
    
    ccol=(UINT)*(pos_ptr+i)/img_rows;
    if( (UINT)*(pos_ptr+i)%img_rows!=0 ) ccol=ccol+1;

    // limit dot region in output image
    img_idx_row_min=max(1,(int)( crow-tmp_row_limit+1 ));
    img_idx_row_max=min((int)( crow+tmp_row_limit ),img_rows);
    
    img_idx_col_min=max(1,(int)( ccol-tmp_col_limit+1 ));
    img_idx_col_max=min((int)( ccol+tmp_col_limit ),img_cols );

    // limit dot region in dot image
    if( 1 <= (int)( crow-tmp_row_limit ) ){
      dot_idx_row_min=1;
      dot_idx_row_max=min(dot_rows,img_idx_row_max-img_idx_row_min+1);
    }else{
      dot_idx_row_min=tmp_row_limit-crow+1;
      if( crow+tmp_row_limit <= img_rows ){
        dot_idx_row_max=dot_rows;
      }else{
        dot_idx_row_max=img_idx_row_max-img_idx_row_min+1;
      }
    }

    if( 1 <= (int)( ccol-tmp_col_limit ) ){
      dot_idx_col_min=1;
      dot_idx_col_max=min(dot_cols,img_idx_col_max-img_idx_col_min+1);
    }else{
      dot_idx_col_min=tmp_col_limit-ccol+1;
      if( ccol+tmp_col_limit <= img_cols ){
        dot_idx_col_max=dot_cols;
      }else{
        dot_idx_col_max=img_idx_col_max-img_idx_col_min+1;
      }
    }
    
    // replace dots to ovals
    for(j=0;j<dot_idx_row_max-dot_idx_row_min+1;j++){
      for(k=0;k<dot_idx_col_max-dot_idx_col_min+1;k++){
        img_pos=(img_idx_col_min+k-1)*img_rows+(img_idx_row_min+j-1);
        dot_pos=(dot_idx_col_min+k-1)*dot_rows+(dot_idx_row_min+j-1);
        
        *(plhs_ptr+img_pos)=
            (1.0-*(alpha_vals+dot_pos))*(*(plhs_ptr+img_pos))+
            (*(alpha_vals+dot_pos))*(*(dot_ptr+dot_pos));
      }
    }
   
  }
  
  return;
}
