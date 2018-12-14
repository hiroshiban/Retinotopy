function[Image] = shiftimage(Image, deltax, deltay)

% Shifts the image IMG using the Fourier shift theorem.
% img_shifted = ShiftImage(img, frac_deltax, frac_deltay)
%
% Shifts the image IMG using the Fourier shift theorem by the 
% Field-of-view (FOV) fractions FRAC_DELTAX and FRAC_DELTAY. 
% The fraction is relative to the size of the image such that 
% a value of 1.0 shifts the image back to where it started. 
% Shifts outside this range will wrap around to the 
% corresponding shift within the range.
%
% The shift is performed using Fourier sinc interpolation, i.e. 
% the Fourier shift theorem, via simple phase adjustments in 
% the frequency domain.  This may lead to Gibbs phenomena.
%
% Dimensions need not be powers of 2 and will not necessarily 
% be padded to a power of 2.  The Matlab FFT functions are 
% capable of non-power of 2 transforms.
%
%  Example:
%      load mri;
%      img = double(squeeze(D(:,:,1,13)));
%      figure;
%      dx = [.1 .5 .8 1.2];
%      dy = [.2 .7 1.0 2.5];
%      for n=1:4,
%          subplot(2,2,n);
%          imagesc( ShiftImage(img,dx(n),dy(n)) );
%          axis image; colormap(gray);
%      end
%
% 01/25/99  Implemented by Edward Brian Welch, edwardbrianwelch@yahoo.com
%
% NOTE:
% This function is partially vectorized (only single loops, 
% no double loops) to gain some benefit in speed.  The tradeoff 
% is that more memory is required to hold the large matrices.
% It would be possible to completely vectorize certain parts 
% of the mfile, but that would require large amounts of memory
% and would also make the code less readable.

[oxdim oydim] = size(Image);

if mod(oxdim,2)==1 & mod(oydim,2)==1,   
   tmp = zeros(oxdim+1,oydim+1);
   tmp(1:oxdim,1:oydim) = Image;
   Image = tmp;
   xdim = oxdim+1;
   ydim = oydim+1;
elseif mod(oxdim,2)==1 & mod(oydim,2)==0,
   tmp = zeros(oxdim+1,oydim);
   tmp(1:oxdim,1:oydim) = Image;
   Image = tmp;
   xdim = oxdim+1;
   ydim = oydim;
elseif mod(oxdim,2)==0 & mod(oydim,2)==1,
   tmp = zeros(oydim+1,oydim);
   tmp(1:oxdim,1:oydim) = Image;
   Image = tmp;
   xdim = oxdim;
   ydim = oydim+1;
else
   xdim = oxdim;
   ydim = oydim;
end

% Determine type of image to return
if isreal(Image),
   real_flag = 1;
else
   real_flag = 0;
end

% Put deltas into the range [-1,1]
while deltax<0,
   deltax = deltax + 2;
end

while deltax>2,
   deltax = deltax - 2;
end

while deltay<0,
   deltay = deltay + 2;
end

while deltay>2,
   deltay = deltay - 2;
end

% Calculate image's center coordinates
xno = (xdim-1)/2;
yno = (ydim-1)/2;


% Forward FFT image rows
Image = fft(Image, xdim, 1);

% Prepare to use the Fourier Shift Theorem
% f(x-deltax) <=> exp(-j*2*pi*deltax*k/N)*F(k)

% Initialize constant part of the exponent
% expression.
cons1 = (-2.0*pi/(xdim)) * deltax * xdim;

% Calculate k values (Nyquist is at x=xno)
k_array = zeros(xdim,1);

for x=1:xdim,    
      if (x-1)<=xno,
         k_array(x) = (x-1);
      else
         k_array(x) = (x-1-xdim);
      end
end

for y=1:ydim,
   
   % Calculate the angles
   angle_array = cons1*k_array;
   
   % Rotate the complex numbers by those angles
   sin_ang = sin(angle_array);
   cos_ang = cos(angle_array);
   newr = real(Image(:,y)).*cos_ang - imag(Image(:,y)).*sin_ang;
   newi = real(Image(:,y)).*sin_ang + imag(Image(:,y)).*cos_ang;
   Image(:,y) = newr + newi*i;
   
end

%---------------------------
% SECOND SHIFT
%---------------------------

Image = ifft(Image, xdim, 1);
Image =  fft(Image, ydim, 2);

% Initialize constant part of the exponent
% expression.
cons1 = (-2.0*pi/(ydim)) * deltay * ydim;

% Calculate k values (Nyquist is at y=yno)
k_array = zeros(ydim,1);

for y=1:ydim,    
      if (y-1)<=yno,
         k_array(y) = (y-1);
      else
         k_array(y) = (y-1-ydim);
      end
end

for x=1:xdim,
   
   % Calculate the angles
   angle_array = cons1*k_array;
   
   % Rotate the complex numbers by those angles
   sin_ang = sin(angle_array);
   cos_ang = cos(angle_array);
   newr = real(Image(x,:)).*cos_ang' - imag(Image(x,:)).*sin_ang';
   newi = real(Image(x,:)).*sin_ang' + imag(Image(x,:)).*cos_ang';
   Image(x,:) = newr + newi*i;
   
end


Image = ifft(Image, ydim, 2);

% Return a Real image if original Image was Real
if real_flag==1,
   Image = real(Image);
end

% Return an Image of the original size (in case it was odd)
Image = Image(1:oxdim,1:oydim);
