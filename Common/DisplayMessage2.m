function DisplayMessage2(message,bgcolor,winPtr,numScreens,drawing_font,drawing_size)

% Displays message on the center of each of multiple PTB windows.
% function DisplayMessage2(message,bgcolor,winPtr,numScreens,drawing_font,drawing_size)
%
% Display message on the center of the left/right (if available)
% screen with your specified background color
%
% [requirement/dependency]
% Psychtoolbox ver.3 or above
%
% [input]
% message : string, you want to display
% bgcolor : background color [r,g,b]
% winPtr  : the parent window pointer
% numScreens   : the number of screens to be used
% drawing_font : option for setting text font (e.g. 'Arial')
% drawing_size : option for setting text size (e.g. 36)
%
% [ouput]
% no output variable
%
% Created: Feb 04 2010 Hiroshi Ban
% Last Update: "2013-11-22 22:53:07 ban (ban.hiroshi@gmail.com)"

% input variable check
if nargin < 3, help(mfilename()); end
if nargin < 4, numScreens=1; end
if nargin < 5, drawing_font='Arial'; end
if nargin < 6, drawing_size=36; end

% get the size of the screen
tmp=Screen(0,'rect');
screen_size=[tmp(3) tmp(4)];

% create background texture
grey_texture=repmat(bgcolor,screen_size(1),screen_size(2));

for ii=1:1:numScreens
  Screen('SelectStereoDrawBuffer',winPtr,ii-1);
  greyScreen=Screen('MakeTexture',winPtr,grey_texture);
  Screen('DrawTexture',winPtr,greyScreen);
  
  % set drawing options
  eval(sprintf('Screen(winPtr,''TextFont'',''%s'');',drawing_font));
  eval(sprintf('Screen(winPtr,''TextSize'',%d);',drawing_size));
  if sum(bgcolor)==0, eval(sprintf('Screen(winPtr,''TextColor'',%d);',255)); end

  % draw formatterd text on the center of the screen
  DrawFormattedText(winPtr,message,'center','center');
  Screen('Close',greyScreen);
end

% display
Screen('DrawingFinished',winPtr,2);
Screen('Flip',winPtr,[],[],[],1);

return
