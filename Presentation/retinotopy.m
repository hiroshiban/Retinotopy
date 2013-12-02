function OK=retinotopy(subj,exp_mode,acq_num)

% a simple wrapper to control all the retinotopy stimulus scripts included in this "Retinotopy" package.
% function retinotopy(subj,exp_mode,acq_num)
%
% - Runs phase-encoded fMRI experiment to delineate borders of retinotopic visual areas
% - This function is a simple wrapper of cretinotopy, cretinotopy_fixtask, and dretinotopy functions
% - Stimuli presented with these 3 functions are as below.
%     * cretinotopy : contrast/color-defined flickering checkerboards with checker luminance change detection task
%     * cretinotopy_fixtask : contrast/color-defined flickering checkerboards with a central fixation task
% - For details, see each function's help
%
% [example]
% >> retinotopy('HB','ccw',1);
% >> retinotopy('HB',{'ccw','exp','ccw','exp'},[1,1,2,2]);
% >> retinotopy('HB',{'ccwwindows','cwwindows','expwindows','contwindows'},[1,1,1,1]);
%
% [input]
% subj    : subject's name, e.g. 'HB'
% exp_mode: experiment mode that you want to run, one of
%           (task -- luminance change detection on the checkerboard for 4 modes below)
%           - ccw   : color/luminance-defined checkerboard wedge rotated counter-clockwisely
%           - cw    : color/luminance-defined checkerboard wedge rotated clockwisely
%           - exp   : color/luminance-defined checkerboard anuulus expanding from fovea
%           - cont  : color/luminance-defined checkerboard annulus contracting from periphery
%           (task -- luminance change detection on the central fixation for 4 modes below)
%           - ccwf  : color/luminance-defined checkerboard wedge rotated counter-clockwisely
%           - cwf   : color/luminance-defined checkerboard wedge rotated clockwisely
%           - expf  : color/luminance-defined checkerboard anuulus expanding from fovea
%           - contf : color/luminance-defined checkerboard annulus contracting from periphery
%           (task -- luminance change detection on the central fixation for 4 modes below)
%           - hrf          : color/luminance-defined checkerboard pattern 16s rest + 6x(16s stimulation + 16s rest) + 16s rest = 240s
%                            to measure HRF responses and to test scanner sequence
%           (task -- luminance change detection on the central fixation for 4 modes below)
%           - localizer    : color/luminance-defined checkerboard pattern 16s rest + 6x(16s stimulation + 16s compensating pattern) + 16s rest = 240s
%                            to identify specific eccentricity corresponding regions
%           (these are stimulus windows to generate pRF (population receptive field) model)
%           - ccwwindows   : stimulation windows of wedge rotated counter-clockwisely
%           - cwwindows    : stimulation windows of wedge rotated clockwisely
%           - expwindows   : stimulation windows of annulus expanding from fovea
%           - contwindows  : stimulation windows of annulus contracting from periphery
%           string, or cell string structure, e.g. 'ccw', or {'ccw','exp'}
%           length(exp_mode) should equal numel(acq_num)
% acq_num : acquisition number, 1,2,3,...
%
% [output]
% OK      : (optional) flag, whether this script finished without any error [true/false]
%
%
% Created    : "2013-11-25 10:14:26 ban (ban.hiroshi@gmail.com)"
% Last Update: "2013-12-02 17:19:44 ban (ban.hiroshi@gmail.com)"


%% check input variables

if nargin<3, help(mfilename()); return; end
if size(exp_mode,1)==1 && ~iscell(exp_mode), exp_mode={exp_mode}; end
if ~isempty(find(acq_num<1,1)), error('acq_num should be 1,2,3,... check input variable'); end
if length(exp_mode)~=numel(acq_num), error('the numbers of exp_mode and acq_num mismatch. check input variable'); end

for ii=1:1:length(exp_mode)
  if ( ~strcmpi(exp_mode{ii},'ccw') && ~strcmpi(exp_mode{ii},'cw') && ...
       ~strcmpi(exp_mode{ii},'exp') && ~strcmpi(exp_mode{ii},'cont') && ...
       ~strcmpi(exp_mode{ii},'ccwf') && ~strcmpi(exp_mode{ii},'cwf') && ...
       ~strcmpi(exp_mode{ii},'expf') && ~strcmpi(exp_mode{ii},'contf') && ...
       ~strcmpi(exp_mode{ii},'HRF') && ~strcmpi(exp_mode{ii},'localizer') && ...
       ~strcmpi(exp_mode{ii},'ccwwindows') && ~strcmpi(exp_mode{ii},'cwwindows') && ...
       ~strcmpi(exp_mode{ii},'expwindows') && ~strcmpi(exp_mode{ii},'contwindows') )

    message=sprintf('\ncan not run exp_mode: %s',exp_mode); disp(message);
    message='exp_mode should be one of ''ccw'', ''cw'', ''exp'', ''cont'','; disp(message);
    message='                          ''ccwf'', ''cwf'', ''expf'', ''contf'', ''hrf'', ''localizer'''; disp(message);
    message='                          ''ccwwindows'', ''cwwindows'', ''expwindows'', ''contwindows'''; disp(message);
    message='check input variables'; disp(message);

    if nargout, OK=false; end
    return;
  end
end

%% set file names

disp_fname='retinotopy_display';

run_fname=cell(length(exp_mode),1);
stim_mode=cell(length(exp_mode),1);
stim_fname=cell(length(exp_mode),1);
for ii=1:1:length(exp_mode)
  if strcmpi(exp_mode{ii},'ccw')
    run_fname{ii}='cretinotopy';  stim_mode{ii}='ccw';  stim_fname{ii}='c_pol';
  elseif strcmpi(exp_mode{ii},'cw')
    run_fname{ii}='cretinotopy';  stim_mode{ii}='cw';   stim_fname{ii}='c_pol';
  elseif strcmpi(exp_mode{ii},'exp')
    run_fname{ii}='cretinotopy';  stim_mode{ii}='exp';  stim_fname{ii}='c_ecc';
  elseif strcmpi(exp_mode{ii},'cont')
    run_fname{ii}='cretinotopy';  stim_mode{ii}='cont'; stim_fname{ii}='c_ecc';
  elseif strcmpi(exp_mode{ii},'ccwf')
    run_fname{ii}='cretinotopy_fixtask';  stim_mode{ii}='ccw';  stim_fname{ii}='c_pol';
  elseif strcmpi(exp_mode{ii},'cwf')
    run_fname{ii}='cretinotopy_fixtask';  stim_mode{ii}='cw';   stim_fname{ii}='c_pol';
  elseif strcmpi(exp_mode{ii},'expf')
    run_fname{ii}='cretinotopy_fixtask';  stim_mode{ii}='exp';  stim_fname{ii}='c_ecc';
  elseif strcmpi(exp_mode{ii},'contf')
    run_fname{ii}='cretinotopy_fixtask';  stim_mode{ii}='cont'; stim_fname{ii}='c_ecc';
  elseif strcmpi(exp_mode{ii},'hrf')
    run_fname{ii}='chrf_fixtask';  stim_mode{ii}='hrf'; stim_fname{ii}='c_hrf';
  elseif strcmpi(exp_mode{ii},'localizer')
    run_fname{ii}='clocalizer_fixtask';  stim_mode{ii}='localizer'; stim_fname{ii}='c_localizer';
  elseif strcmpi(exp_mode{ii},'ccwwindows')
    run_fname{ii}='gen_retinotopy_windows'; stim_mode{ii}='ccw'; stim_fname{ii}='c_pol';
  elseif strcmpi(exp_mode{ii},'cwwindows')
    run_fname{ii}='gen_retinotopy_windows'; stim_mode{ii}='cw'; stim_fname{ii}='c_pol';
  elseif strcmpi(exp_mode{ii},'expwindows')
    run_fname{ii}='gen_retinotopy_windows'; stim_mode{ii}='exp'; stim_fname{ii}='c_ecc';
  elseif strcmpi(exp_mode{ii},'contwindows')
    run_fname{ii}='gen_retinotopy_windows'; stim_mode{ii}='cont'; stim_fname{ii}='c_ecc';
  end
end

%% set additional parameters to reconstruct stimlus windows
for ii=1:1:length(exp_mode)
  if ( strcmpi(exp_mode{ii},'ccwwindows') || strcmpi(exp_mode{ii},'cwwindows') || ...
       strcmpi(exp_mode{ii},'expwindows') || strcmpi(exp_mode{ii},'contwindows') )
    overwrite_pix_per_deg=10;
    TR=2;
  end
end

%% check directory with subject name

% [NOTE]
% if the subj directory is not found, create subj directory, copy all condition
% files from DEFAULT and then run the script using DEFAULT parameters

subj_dir=fullfile(pwd,'subjects',subj);
if ~exist(subj_dir,'dir')

  disp('The subject directory was not found.');
  user_response=0;
  while ~user_response
    user_entry = input('Do you want to proceed using DEFAULT parameters? (y/n) : ', 's');
    if(user_entry == 'y')
      fprintf('Generating subj directory using DEFAULT parameters...');
      user_response=1; %#ok
      break;
    elseif (user_entry == 'n')
      disp('quiting the script...');
      if nargout, OK=false; end
      return;
    else
      disp('Please answer y or n!'); continue;
    end
  end

  %mkdir(subj_dir);
  copyfile(fullfile(pwd,'subjects','_DEFAULT_'),subj_dir);
end


%% present stimuli or generate stimulus windows
for ii=1:1:length(exp_mode)
  % generate stimulus windows
  if ( strcmpi(exp_mode{ii},'ccwwindows') || strcmpi(exp_mode{ii},'cwwindows') || ...
       strcmpi(exp_mode{ii},'expwindows') || strcmpi(exp_mode{ii},'contwindows') )
    main_exp_name=sprintf('%s(''%s'',''%s'',%d,''%s'',''%s'',%d,%d);',...
                          run_fname{ii},subj,stim_mode{ii},acq_num(ii),disp_fname,stim_fname{ii},overwrite_pix_per_deg,TR);
    eval(main_exp_name);
  % display stimuli
  else
    main_exp_name=sprintf('%s(''%s'',''%s'',%d,''%s'',''%s'');',...
                          run_fname{ii},subj,stim_mode{ii},acq_num(ii),disp_fname,stim_fname{ii});
    eval(main_exp_name);
  end
end

if nargout, OK=true; end

return
