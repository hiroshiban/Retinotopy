function script_gen_all_windows_BVQX_hbtools(subj,pix_per_deg,TR)

% a simple script to generate all the retinotopy stimulus windows for pRF analyses, which are compatible with the BVQX_hbtools's pRF analysis routines.
% function script_gen_all_windows_BVQX_hbtools(subj,:pix_per_deg,:TR)
% (: is optional)
%
% This is a simple script to generate all the retinotopy stimulus windows for pRF analyses.
% The generated files can be directly applied to the BVQX_hbtools's pRF analysis pipeline.
% For details of the stimulus window generation, please see help documents of gen_*_windows
% functions.
%
% [example]
% >> script_gen_all_windows_BVQX_hbtools('2d',[10,20],[1,2]);
%
% [input]
% subj  : subject's name, e.g. 'HB'
% pix_per_deg : (optional) pixels-per-deg value used in generating stimulus windows.
%         if not specified (empty), sparam.pix_per_deg is used to reconstruct stim_windows.
%         if specified, sparam.pix_per_deg is overwritten by this value, which may be
%         handy in some case with providing stim_windows with less memory space.
%         1/pix_per_deg = spatial resolution of the generated visual field,
%         e.g. when pix_per_deg=20, then, 1 pixel = 0.05 deg.
%         multiple values can be accepted. [10,20] by default.
% TR    : (optional) TR used in fMRI scans, in sec. multiple values can be accepted.
%         [1,2] by default.
%
% [output]
% no output variable.
% all the stimulus windows are stored in ~/Retinotopy/Presentation/subjects/(subj_name)/results/(date)/pRF.
%
%
% Created    : "2019-02-28 17:46:17 ban"
% Last Update: "2019-03-03 11:15:01 ban"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check the input variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<1, help(mfilename()); return; end
if nargin<2 || isempty(pix_per_deg), pix_per_deg=[10,20]; end
if nargin<3 || isempty(TR), TR=[1,2]; end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check whether the subject directory already exists
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [NOTE]
% if the subj directory is not found, the directory is created with coping
% all condition files from DEFAULT and then this function tries to run the
% stimulus presentation script using the DEFAULT parameters

subj_dir=fullfile(fileparts(mfilename('fullpath')),'subjects',num2str(subj));
if ~exist(subj_dir,'dir')

  fprintf('The subject directory was not found.\n');
  user_response=0;
  while ~user_response
    user_entry = input('Do you want to proceed using DEFAULT parameters? (y/n) : ', 's');
    if(user_entry == 'y')
      fprintf('Generating subj directory using DEFAULT parameters...');
      user_response=1; %#ok
      break;
    elseif (user_entry == 'n')
      fprintf('quiting the script...\n');
      if nargout, OK=false; end
      return;
    else
      fprintf('Please answer y or n!\n'); continue;
    end
  end

  %mkdir(subj_dir);
  copyfile(fullfile(fileparts(mfilename('fullpath')),'subjects','_DEFAULT_'),subj_dir);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% generate stimulus windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generating stimulus windows
resultDir=fullfile(subj_dir,'pRF',datestr(now,'yymmdd'));
for pp=1:1:numel(pix_per_deg)
  for tt=1:1:numel(TR)

    % the standard rotating wedge and expanding/contracting annulus.
    stim_windows={'ccw','cw','exp','cont'};
    stim_files={'c_pol','c_pol','c_ecc','c_ecc'};
    for ww=1:1:length(stim_windows)
      gen_retinotopy_windows(subj,stim_windows{ww},1,'retinotopy_display',stim_files{ww},pix_per_deg(pp),TR(tt));
      % convert stimulus window file name so as to be accepted by BVQX_hbtools
      movefile(fullfile(resultDir,[num2str(subj),sprintf('_stimulus_window_%s_run_01.mat',stim_windows{ww})]),...
               fullfile(resultDir,sprintf('stimulus_window_%s_ppd_%d_TR_%d.mat',stim_windows{ww},pix_per_deg(pp),TR(tt))));
    end

    % bar stimulus
    gen_bar_windows(subj,'bar',1,'retinotopy_display','c_bar',pix_per_deg(pp),TR(tt));
    movefile(fullfile(resultDir,[num2str(subj),'_stimulus_window_bar_run_01.mat']),...
             fullfile(resultDir,sprintf('stimulus_window_bar_ppd_%d_TR_%d.mat',pix_per_deg(pp),TR(tt))));

    % multifocal: please check whether the m-sequence described in c_multifocal matches with your actual stimulus
    gen_multifocal_windows(subj,'multifocal',1,'retinotopy_display','c_multifocal',pix_per_deg(pp),TR(tt));
    movefile(fullfile(resultDir,[num2str(subj),'_stimulus_window_multifocal_run_01.mat']),...
             fullfile(resultDir,sprintf('stimulus_window_multifocal_ppd_%d_TR_%d.mat',pix_per_deg(pp),TR(tt))));

    % dual (rotating wedge + expanding/contracting annulus) stimulus windows
    stim_windows={'ccwexp','ccwcont','cwexp','cwcont'};
    for ww=1:1:length(stim_windows)
      gen_dual_windows(subj,stim_windows{ww},1,'retinotopy_display','c_dual',pix_per_deg(pp),TR(tt));
      movefile(fullfile(resultDir,[num2str(subj),sprintf('_stimulus_window_%s_run_01.mat',stim_windows{ww})]),...
               fullfile(resultDir,sprintf('stimulus_window_%s_ppd_%d_TR_%d.mat',stim_windows{ww},pix_per_deg(pp),TR(tt))));
    end

  end % for tt=1:1:numel(TR)
end % for pp=1:1:numel(pix_per_deg)

return
