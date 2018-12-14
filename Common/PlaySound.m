function PlaySound(high_flg)

% function PlaySound(high_flg)
%
% Play sound with high/low tone to notify the processing
%
% [input]
% high_flg  : if 1, high-tone sound will be played
%             if 0, low-tone sound will be played
%
%
% Created    : "2012-05-29 04:09:02 ban"
% Last Update: "2012-05-29 16:32:07 ban"

if nargin<1 || isempty(high_flg), high_flg=1; end
try
  if high_flg % high-tone
    sound(sin(2*pi*0.2*(0:900)),22000);
  else % low-tone
    sound(sin(2*pi*0.012*(0:900)),22000);
  end
catch %#ok
  disp('finished.');
end
