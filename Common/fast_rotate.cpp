#include <mex.h>
#include <math.h>

const double PI = 3.14159265358979323846;

/*
 This function will replace imrotate(image,angle,'crop') for any 3 dims image, UINT8 class.
 Work ten times faster, tested on matlab 7, VC6.
 Compile it using the mex tools -
 mex fast_rotate.cpp.
*/ 

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 2) mexErrMsgTxt("Usage : fast_rotate(image,ang)");
    float angle = (float)mxGetScalar(prhs[1]);
    const int *dims = mxGetDimensions(prhs[0]);
    int width = dims[0];
    int height = dims[1];
    const int num_of_dims=mxGetNumberOfDimensions(prhs[0]);
    int dim = 1; // Number of colors (default - gray scale)
    if(num_of_dims==3) dim=dims[2];
    
    unsigned char * source;
    unsigned char * dest;
    
    // Here need to insert the 0,90,180,360 special cases.

    const float rad = (float)((angle*PI)/180.0),
    ca=(float)cos(rad), sa=(float)sin(rad);

    const float 
      ux  = (float)(abs(width*ca)),  uy  = (float)(abs(width*sa)),
      vx  = (float)(abs(height*sa)), vy  = (float)(abs(height*ca)),
      w2  = 0.5f*width,           h2  = 0.5f*height,
      dw2 = 0.5f*(ux+vx),         dh2 = 0.5f*(uy+vy); // dw2, dh2 are the dimentions for rotated image without cropping.

    plhs[0] = mxCreateNumericArray(num_of_dims, dims, mxUINT8_CLASS, mxREAL);
    
    source=(unsigned char *)mxGetData(prhs[0]);
    dest=(unsigned char *)mxGetData(plhs[0]);


    int X,Y; // Locations in the source matrix
    int x,y,color; // For counters
    int index_Color,index_Height;
    
    for(color=0;color<dim;color++)
    {
        index_Color=color*height*width;
        for(y=0;y<height;y++)
        {
            index_Height=index_Color+y*width;
            for(x=0;x<width;x++)
            {
                X=(int)(w2 + (x-w2)*ca + (y-h2)*sa+0.5); // Source X
                Y=(int)(h2 - (x-w2)*sa + (y-h2)*ca+0.5); // Source Y
                //X=(int)(w2 + (x-dw2)*ca + (y-dh2)*sa); // Source X- without cropping
                //Y=(int)(h2 - (x-dw2)*sa + (y-dh2)*ca); // Source Y- without cropping
        
                dest[index_Height+x] = (X<0 || Y<0 || X>=width || Y>=height)?0:source[index_Color+Y*width+X];
            }
        }
    }
}
