function update_Retinotopy_html_docs(style)

% Updates all the HTML-based documents of Retinotopy.
% function update_Retinotopy_html_docs(:style)
% (: is optional)
%
% This function updates html-based documents of Retinotopy
%
% [input]
% style : (optional) if 0, a default CSS/TPL templates will be applied in
%         generating HTML-based help documents, while Hiroshi's customized
%         templates will be applied if this value is non-zero. 0 by default.
%
% [output]
% new html-baesd documents will be generated in
% ~/Retinotopy/doc
%
%
% Created    : "2013-11-26 10:31:46 ban (ban.hiroshi@gmail.com)"
% Last Update: "2016-08-29 13:40:30 ban"

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

% selecting the style of the HTML-based help documents of BVQX_hbtools.
if style
  % when you want to generate HTML-based help documents using Hiroshi's customized template
  m2html('mfiles',tgt_path,'htmldir',docpath,'recursive','on','globalHypertextLinks','on','template','BVQX_hbtools','index','menu');
else
  m2html('mfiles',tgt_path,'htmldir',docpath,'recursive','on','globalHypertextLinks','on','template','blue');
end

cd('Retinotopy');

disp(' ');
disp('completed.');

% remove path to m2html
rmpath(m2htmlpath);

return
