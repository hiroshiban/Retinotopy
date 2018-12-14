function bigsubplot(rows,cols,rr,cc,hgap,vgap)

% Sub-plots data with bigger sub-windows.
% bigsubplot(rows,cols,rr,cc,[hgap],[vgap])
% 
% create subplots bigger than standard
%
%  input:
%   - rows: number of rows in desired subplot
%   - cols: number of columns in desired subplot
%   - rr: row position of next image to be plotted
%   - cc: col position of next image to be plotted
%   - hgap: horizontal margin (in %?) [optional: default = 0.06]
%   - vgap: vertical margin (in %?) [optional: default = hgap]
  
if nargin < 5, hgap = 0.06; end
if nargin < 6, vgap = hgap; end

wid = (1.0-hgap)/cols;
pos(1) = (cc-1)*wid+hgap;
pos(3) = wid-hgap;

if length(vgap) == 1
    % the plot is centered vertically
    hei = (1.0-vgap)/rows;
    pos(2) = (rows-rr)*hei+vgap;
    pos(4) = hei-vgap;
else
    % the plot is not centered: vgap = [bottomgap topgap]
    hei = 1.0/rows;
    pos(2) = (rows-rr)*hei + vgap(1);
    pos(4) = hei - sum(vgap);
end
subplot('position',pos);
