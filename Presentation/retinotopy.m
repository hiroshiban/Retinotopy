function OK=retinotopy(subj,exp_mode,acq_num)

% a simple wrapper to control all the retinotopy stimulus scripts included in this "Retinotopy" package.
% function OK=retinotopy(subj,exp_mode,acq_num)
%
% This function is a simple wrapper to control phase-encoded/pRF retinotopy stimuli.
% The fMRI responses for the stimuli can be utilized to delineate borders of retinotopic visual areas.
% The details of the wrapped functions are as below.
%     1. cretinotopy           : color/luminance-defined checkerboard stimuli with a checker-pattern luminance detection task, for phase-encoded analysis
%     2. cretinotopy_fixtask   : color/luminance-defined checkerboard stimuli with a fixation luminance detection task, for phase-encoded analysis
%     3. cbar                  : color/luminance-defined checkerboard bar stimuli with a checker-pattern luminance detection task, for pRF analysis
%     4. cbar_fixtask          : color/luminance-defined checkerboard bar stimuli with a fixation luminance detection task, for pRF analysis
%     5. cmultifocal           : color/luminance-defined multifocal retinotopy checkerboard stimuli with a checker-pattern luminance detection task, for GLM or pRF analysis
%     6. cmultifocal_fixtask   : color/luminance-defined multifocal retinotopy checkerboard stimuli with a fixation luminance detection task, for GLM or pRF analysis
%     7. chrf_fixtask          : color/luminance-defined checkerboard stimuli with a fixation luminance detection task, for HRF shape estimation
%     8. clgnlocalizer_fixtask : color/luminance-defined checkerboard stimuli with a fixation luminance detection task, for localizing LGN
%     9. clocalizer_fixtask    : color/luminance-defined checkerboard stimuli with a fixation luminance detection task, for identify retinotopic subregions
%    10. gen_retinotopy_windows: a script for generating phase-encoded stimulus windows of ccw/cw/exp/cont, for pRF analysis
%    11. gen_bar_windows       : a script for generating a standard pRF bar stimulus windows, for pRF analysis
%    12. gen_multifocal_windows: a script for generating multifocal retinoopy checkerboard stimulus windows, for pRF analysis
% For details, see each function's help.
%
% [example]
% >> retinotopy('HB','ccw',1);
% >> retinotopy('HB',{'ccw','exp','ccw','exp'},[1,1,2,2]);
% >> retinotopy('HB',{'ccwwindows','cwwindows','expwindows','contwindows'},[1,1,1,1]);
%
% [input]
% subj    : subject's name, e.g. 'HB'
% exp_mode: experiment mode that you want to run, one of
%           (task -- luminance change detection on the checkerboard)
%           - ccw   : color/luminance-defined checkerboard wedge rotated counter-clockwisely
%           - cw    : color/luminance-defined checkerboard wedge rotated clockwisely
%           - exp   : color/luminance-defined checkerboard anuulus expanding from fovea
%           - cont  : color/luminance-defined checkerboard annulus contracting from periphery
%           - bar   : color/luminance-defined checkerboard bar, a standard pRF (population receptive field) stimulus
%           - multifocal : color/luminance-defined checkerboard for a standard multifocal retinotopy stimulus
%           (task -- luminance change detection on the central fixation)
%           - ccwf  : color/luminance-defined checkerboard wedge rotated counter-clockwisely
%           - cwf   : color/luminance-defined checkerboard wedge rotated clockwisely
%           - expf  : color/luminance-defined checkerboard anuulus expanding from fovea
%           - contf : color/luminance-defined checkerboard annulus contracting from periphery
%           - barf  : color/luminance-defined checkerboard bar, a standard pRF (population receptive field) stimulus
%           - multifocalf : color/luminance-defined checkerboard for a standard multifocal retinotopy stimulus
%           (task -- luminance change detection on the central fixation)
%           - hrf          : color/luminance-defined checkerboard pattern 16s rest + 6x(16s stimulation + 16s rest) + 16s rest = 240s
%                            to measure HRF responses and to test scanner sequence
%           (task -- luminance change detection on the central fixation)
%           - localizer    : color/luminance-defined checkerboard pattern 16s rest + 6x(16s stimulation + 16s compensating pattern) + 16s rest = 240s
%                            to identify specific eccentricity corresponding regions
%           (these are stimulus windows to generate pRF (population receptive field) model)
%           - ccwwindows   : stimulation windows of wedge rotated counter-clockwisely
%           - cwwindows    : stimulation windows of wedge rotated clockwisely
%           - expwindows   : stimulation windows of annulus expanding from fovea
%           - contwindows  : stimulation windows of annulus contracting from periphery
%           - barwindows   : stimulation windows of a standard pRF bar
%           - multifocalwindows : stimulation windows of a standard multifocal retinotopy stimulus
%           string, or cell string structure, e.g. 'ccw', or {'ccw','exp'}
%           length(exp_mode) should equal numel(acq_num)
% acq_num : acquisition number, 1,2,3,...
%
% [output]
% OK      : (optional) flag, whether this script finished without any error [true/false]
%
%
% Created    : "2013-11-25 10:14:26 ban"
% Last Update: "2018-12-01 13:56:15 ban"


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check the input variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<3, help(mfilename()); return; end
if size(exp_mode,1)==1 && ~iscell(exp_mode), exp_mode={exp_mode}; end
if ~isempty(find(acq_num<1,1)), error('acq_num should be 1,2,3,... check input variable'); end
if length(exp_mode)~=numel(acq_num), error('the numbers of exp_mode and acq_num mismatch. check input variable'); end

for ii=1:1:length(exp_mode)
  if ( ~strcmpi(exp_mode{ii},'ccw') && ~strcmpi(exp_mode{ii},'cw') && ...
       ~strcmpi(exp_mode{ii},'exp') && ~strcmpi(exp_mode{ii},'cont') && ~strcmpi(exp_mode{ii},'bar') && ...
       ~strcmpi(exp_mode{ii},'ccwf') && ~strcmpi(exp_mode{ii},'cwf') && ...
       ~strcmpi(exp_mode{ii},'expf') && ~strcmpi(exp_mode{ii},'contf') && ~strcmpi(exp_mode{ii},'barf') &&...
       ~strcmpi(exp_mode{ii},'multifocal') && ~strcmpi(exp_mode{ii},'multifocalf') && ...
       ~strcmpi(exp_mode{ii},'HRF') && ~strcmpi(exp_mode{ii},'localizer') && ...
       ~strcmpi(exp_mode{ii},'ccwwindows') && ~strcmpi(exp_mode{ii},'cwwindows') && ...
       ~strcmpi(exp_mode{ii},'expwindows') && ~strcmpi(exp_mode{ii},'contwindows') && ...
       ~strcmpi(exp_mode{ii},'barwindows') && ~strcmpi(exp_mode{ii},'multifocalwindows') )

    message=sprintf('\ncan not run exp_mode: %s',exp_mode{ii}); disp(message);
    message='exp_mode should be one of ''ccw'', ''cw'', ''exp'', ''cont'', ''bar'', ''multifocal'','; disp(message);
    message='                          ''ccwf'', ''cwf'', ''expf'', ''contf'', ''barf'', ''multifocalf'', ''hrf'', ''localizer'','; disp(message);
    message='                          ''ccwwindows'', ''cwwindows'', ''expwindows'', ''contwindows'', ''barwindows'','; disp(message);
    message='                          ''multifocalwindows'''; disp(message);
    message='check the input variables'; disp(message);

    if nargout, OK=false; end
    return;
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set script names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
  elseif strcmpi(exp_mode{ii},'bar')
    run_fname{ii}='cbar';  stim_mode{ii}='bar'; stim_fname{ii}='c_bar';
  elseif strcmpi(exp_mode{ii},'multifocal')
    run_fname{ii}='cmultifocal';  stim_mode{ii}='multifocal'; stim_fname{ii}='c_multifocal';
  elseif strcmpi(exp_mode{ii},'ccwf')
    run_fname{ii}='cretinotopy_fixtask';  stim_mode{ii}='ccw';  stim_fname{ii}='c_pol';
  elseif strcmpi(exp_mode{ii},'cwf')
    run_fname{ii}='cretinotopy_fixtask';  stim_mode{ii}='cw';   stim_fname{ii}='c_pol';
  elseif strcmpi(exp_mode{ii},'expf')
    run_fname{ii}='cretinotopy_fixtask';  stim_mode{ii}='exp';  stim_fname{ii}='c_ecc';
  elseif strcmpi(exp_mode{ii},'contf')
    run_fname{ii}='cretinotopy_fixtask';  stim_mode{ii}='cont'; stim_fname{ii}='c_ecc';
  elseif strcmpi(exp_mode{ii},'barf')
    run_fname{ii}='cbar_fixtask';  stim_mode{ii}='bar'; stim_fname{ii}='c_bar';
  elseif strcmpi(exp_mode{ii},'multifocalf')
    run_fname{ii}='cmultifocal_fixtask';  stim_mode{ii}='multifocal'; stim_fname{ii}='c_multifocal';
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
  elseif strcmpi(exp_mode{ii},'barwindows')
    run_fname{ii}='gen_bar_windows'; stim_mode{ii}='bar'; stim_fname{ii}='c_bar';
  elseif strcmpi(exp_mode{ii},'multifocalwindows')
    run_fname{ii}='gen_multifocal_windows'; stim_mode{ii}='multifocal'; stim_fname{ii}='c_multifocal';
  end
end

%% set additional parameters to reconstruct stimlus windows
for ii=1:1:length(exp_mode)
  if ( strcmpi(exp_mode{ii},'ccwwindows') || strcmpi(exp_mode{ii},'cwwindows') || ...
       strcmpi(exp_mode{ii},'expwindows') || strcmpi(exp_mode{ii},'contwindows') || ...
       strcmpi(exp_mode{ii},'barwindows') || strcmpi(exp_mode{ii},'multifocalwindows') )
    overwrite_pix_per_deg=20;
    TR=2;
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check whether the subject directory already exists
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set the gamma table. please change the line below to use your measurements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% loading gamma_table
%load(fullfile('..','gamma_table','ASUS_ROG_Swift_PG278Q','181003','cbs','gammatablePTB.mat'));
%load(fullfile('..','gamma_table','ASUS_VG278HE','181003','cbs','gammatablePTB.mat'));
%load(fullfile('..','gamma_table','MEG_B1','151225','cbs','gammatablePTB.mat'));
gammatable=repmat(linspace(0.0,1.0,256),3,1)'; %#ok % a simple linear gamma


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% present stimuli or generate stimulus windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii=1:1:length(exp_mode)

  % generate stimulus windows
  if ( strcmpi(exp_mode{ii},'ccwwindows') || strcmpi(exp_mode{ii},'cwwindows') || ...
       strcmpi(exp_mode{ii},'expwindows') || strcmpi(exp_mode{ii},'contwindows') || ...
       strcmpi(exp_mode{ii},'barwindows') || strcmpi(exp_mode{ii},'multifocalwindows') )
    main_exp_name=sprintf('%s(''%s'',''%s'',%d,''%s'',''%s'',%d,%d);',...
                          run_fname{ii},subj,stim_mode{ii},acq_num(ii),disp_fname,stim_fname{ii},overwrite_pix_per_deg,TR);
  % stimulus presentation
  else
    main_exp_name=sprintf('%s(''%s'',''%s'',%d,''%s'',''%s'',gammatable);',...
                          run_fname{ii},subj,stim_mode{ii},acq_num(ii),disp_fname,stim_fname{ii});
  end

  eval(main_exp_name);
end

if nargout, OK=true; end

return
