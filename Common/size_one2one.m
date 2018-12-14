function size_one2one(im_h)

% Displays an image in true size without any scaling
% function size_one2one(im_h)
%
% This fucntion displays an image in true size without any scaling
%
% [input]
% im_h : handle of the image you want to visualize
%        e.g. im_h = imagesc(M); (here, M is image [row,col])
%
% [output]
% no output, the image attached im_h will be displayed
%
% Created: "2010-04-03 14:48:48 ban"
% Last Update: "2013-11-22 23:52:52 ban (ban.hiroshi@gmail.com)"

ax_h = gca;
fig_h = gcf;

iw = size(get(im_h, 'CData'), 2);
ih = size(get(im_h, 'CData'), 1);

set(ax_h, 'Units', 'pixels');
set(fig_h, 'Units', 'pixels');
set(0, 'Units', 'pixels');

figurePos = get(fig_h, 'Position');

dap = get(0,'DefaultAxesPosition');

brdr_wi = round((1 - dap(3)) * iw / dap(3));
brdr_he = round((1 - dap(4)) * ih / dap(4));
brdr_le = floor(brdr_wi/2);
brdr_bo = floor(brdr_he/2);

RDS_fig_wi = iw + brdr_wi;
RDS_fig_he = ih + brdr_he;

%figurePos(1) = figurePos(1) - floor((RDS_fig_wi - figurePos(3))/2);
%figurePos(2) = figurePos(2) - floor((RDS_fig_he - figurePos(4))/2);
figurePos(1) = 0;
figurePos(2) = 0;
figurePos(3) = RDS_fig_wi;
figurePos(4) = RDS_fig_he;

axesPos(1) = brdr_le + 1;
axesPos(2) = brdr_bo + 1;
axesPos(3) = iw;
axesPos(4) = ih;

set(fig_h, 'Position', figurePos)
set(ax_h, 'Position', axesPos);

drawnow;

return;
