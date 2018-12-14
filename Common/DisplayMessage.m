function DisplayMessage(message,bgcolor,screens,drawing_font,drawing_size)

% Display message on a PTB window.
% function DisplayMessage(message,bgcolor,scrren_size)
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
% screens : the cell array of PTB screens (e.g. leftEyeWindow)
% drawing_font : option for setting text font (e.g. 'Arial')
% drawing_size : option for setting text size (e.g. 36)
%
% [ouput]
% no output variable
%
% Created: Feb 04 2010 Hiroshi Ban
% Last Update: "2013-11-22 22:51:58 ban (ban.hiroshi@gmail.com)"

% input variable check
if nargin < 3, help DisplayMessage; end
if nargin < 4, drawing_font='Arial'; end
if nargin < 5, drawing_size=36; end

% get the size of the screen
tmp=Screen(0,'rect');
screen_size=[tmp(3) tmp(4)];

% create background texture
grey_texture=repmat(bgcolor,screen_size(1),screen_size(2));

% loop for the number of PTB screens
greyScreen=cell(length(screens),1);
for ii=1:1:length(screens)
  % fill the background
  greyScreen{ii}=Screen('MakeTexture',screens{ii},grey_texture);
  Screen('DrawTexture',screens{ii},greyScreen{ii});
  
  % set drawing options
  eval(sprintf('Screen(screens{ii},''TextFont'',''%s'');',drawing_font));
  eval(sprintf('Screen(screens{ii},''TextSize'',%d);',drawing_size));
  if sum(bgcolor)==0
    eval(sprintf('Screen(screens{ii},''TextColor'',%d);',255));
  end
    
  % draw formatterd text on the center of the screen
  DrawFormattedText(screens{ii},message,'center','center');
end

% display
Screen('DrawingFinished',screens{1},2);
Screen('Flip',screens{1},[],[],[],1);

return
