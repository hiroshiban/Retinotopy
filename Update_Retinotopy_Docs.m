function Update_Retinotopy_Docs()

% Updates all the HTML-based documents of Retinotopy.
% function Update_Retinotopy_Docs()
%
% This function updates html-based documents of Retinotopy
%
% [input]
% no input variable
%
% [output]
% new html-baesd documents will be generated in
% ~/Retinotopy/doc
%
%
% Created    : "2013-11-26 10:31:46 ban (ban.hiroshi@gmail.com)"
% Last Update: "2013-11-26 10:32:28 ban (ban.hiroshi@gmail.com)"

% add path to m2html
m2htmlpath=fullfile(fileparts(mfilename('fullpath')),'m2html');
addpath(m2htmlpath);

docpath=fullfile(fileparts(mfilename('fullpath')),'doc','html');
if exist(docpath,'dir'), rmdir(docpath,'s'); end

% generate html-based documents
disp('Updating Retinotopy documents....');
disp(' ');

cd('..');
%tgt_path={'Retinotopy/Common','Retinotopy/Generation','Retinotopy/Presentation','Retinotopy/gamma_table'};
tgt_path={'Retinotopy/Common','Retinotopy/Generation','Retinotopy/Presentation','Retinotopy/pRF'};
m2html('mfiles',tgt_path,'htmldir',docpath,'recursive','on','globalHypertextLinks','on');
cd('Retinotopy');

disp(' ');
disp('completed.');

% remove path to m2html
addpath(m2htmlpath);

return
