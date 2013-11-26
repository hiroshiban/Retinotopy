function zarray=Pad2Array(array,pad,mode)

% Pads a specific number between elements of the input array.
% function zarray=Pad2Array(array,:pad,:mode)
% (: is optional)
%
% This function pads a specific number between elements of the input array.
% e.g. array=[1,2,3,4,5]; ---> zarray=[1,0,2,0,3,0,4,0];
%
% [input]
% array  : input array, PxN vector. the array is processed along COLUMN.
% pad    : (optional) pad number. the input array will be interposed like
%          1,2,3,... ---> 1,pad,2,pad,3,pad...
% mode   : (optional) 0- pad zeros in odd sequences, 1- pad zeros to even sequenes
%          0 by default.
%
% [output]
% zarray : output array, padded by zero.
%
%
% Created    : "2013-11-22 15:46:14 ban (ban.hiroshi@gmail.com)"
% Last Update: "2013-11-22 23:35:01 ban (ban.hiroshi@gmail.com)"

% check input variable
if nargin<1 help(mfilename()); return; end
if nargin<2 || isempty(pad), pad=0; end
if nargin<3 || isempty(mode), mode=0; end

% processing
array=array';
if mode==0
  zarray=[array,pad*ones(size(array))]';
elseif mode==1
  zarray=[pad*ones(size(array)),array]';
else
  error('mode should be 0 or 1. check input variable.');
end
zarray=(reshape(zarray,size(array,2),2*size(array,1)));

return
