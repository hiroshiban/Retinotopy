function OK=retinotopy(subj,exp_mode,acq_num,overwrite_pix_per_deg,TR)

% a simple wrapper to control all the retinotopy stimulus scripts included in this "Retinotopy" package.
% function OK=retinotopy(subj,exp_mode,acq_num,:overwrite_pix_per_deg,:TR)
% (: is optional)
%
% This function is a simple wrapper to control phase-encoded/pRF retinotopy stimuli.
% The fMRI responses evoked by the stimuli can be utilized to delineate borders of retinotopic visual areas etc.
% The wrapped functions are as below.
%     1. cretinotopy           : color/luminance-defined checkerboard stimuli with a checker-pattern luminance change detection task, for phase-encoded analysis
%     2. cretinotopy_fixtask   : color/luminance-defined checkerboard stimuli with a fixation luminance change detection task, for phase-encoded analysis
%     3. cbar                  : color/luminance-defined checkerboard bar stimuli with a checker-pattern luminance change detection task, for pRF analysis
%     4. cbar_fixtask          : color/luminance-defined checkerboard bar stimuli with a fixation luminance change detection task, for pRF analysis
%     5. cdual                 : color/luminance-defined checkerboard stimuli (polar wedge + eccentricity annulus) with a checker-pattern luminance change detection task, for phase-encoded/pRF analysis
%     6. cdual_fixtask         : color/luminance-defined checkerboard stimuli (polar wedge + eccentricity annulus) with a fixation luminance change detection task, for phase-encoded/pRF analysis
%     7. cmultifocal           : color/luminance-defined multifocal retinotopy checkerboard stimuli with a checker-pattern luminance change detection task, for GLM or pRF analysis
%     8. cmultifocal_fixtask   : color/luminance-defined multifocal retinotopy checkerboard stimuli with a fixation luminance change detection task, for GLM or pRF analysis
%     9. cmeridian             : color/luminance-defined dual wedge checkerboard stimuli presented along the horizontal or vertical visual meridian with a checker-pattern luminance change detection task
%    10. cmeridian_fixtask     : color/luminance-defined dual wedge checkerboard stimuli presented along the horizontal or vertical visual meridian with a fixation luminance change change detection task
%    11. chrf                  : color/luminance-defined checkerboard stimuli with a checker-pattern luminance change detection task, for HRF shape estimation
%    12. chrf_fixtask          : color/luminance-defined checkerboard stimuli with a fixation luminance change detection task, for HRF shape estimation
%    13. clgnlocalizer         : color/luminance-defined checkerboard stimuli with a checker-pattern luminance change detection task, for localizing LGN
%    14. clgnlocalizer_fixtask : color/luminance-defined checkerboard stimuli with a fixation luminance change detection task, for localizing LGN
%    15. clocalizer            : color/luminance-defined checkerboard stimuli with a checker-pattern luminance change detection task, for identify retinotopic subregions
%    16. clocalizer_fixtask    : color/luminance-defined checkerboard stimuli with a fixation luminance change detection task, for identify retinotopic subregions
%    17. gen_retinotopy_windows: a function for generating checkerboard stimulus windows of ccw/cw/exp/cont, for phase-encoded/pRF analysis
%    18. gen_bar_windows       : a function for generating standard pRF bar stimulus windows, for pRF analysis
%    19. gen_dual_windows      : a function for generating checkerboard (wedge + annulus) stimulus windows, for phase-encoded/pRF analysis
%    20. gen_multifocal_windows: a function for generating multifocal retinoopy checkerboard stimulus windows, for pRF analysis
% For more details, please see each function's help.
%
% [example]
% >> retinotopy('HB','ccw',1);
% >> retinotopy('HB',{'ccw','exp','ccw','exp'},[1,1,2,2]);
% >> retinotopy('HB',{'ccwwindows','cwwindows','expwindows','contwindows'},[1,1,1,1]);
%
% [input]
% subj    : subject's name, e.g. 'HB'
% exp_mode: experiment mode that you want to run, one of
%
%           *** task -- luminance change detection on the checkerboard
%           - ccw     : color/luminance-defined checkerboard wedge rotating counter-clockwisely
%           - cw      : color/luminance-defined checkerboard wedge rotating clockwisely
%           - exp     : color/luminance-defined checkerboard annulus expanding from fovea
%           - cont    : color/luminance-defined checkerboard annulus contracting from periphery
%           - bar     : color/luminance-defined checkerboard bar, a standard pRF (population receptive field) stimulus
%           - ccwexp  : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
%           - ccwcont : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
%           - cwexp   : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
%           - cwcont  : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
%           - multifocal : color/luminance-defined checkerboard for a standard multifocal retinotopy stimulus
%           - meridian : color/luminance-defined dual wedge checkerboard presented along the horizontal or vertical visual meridian
%           - lgn     : color/luminance-defined checkerboard hemifield wedge pattern 16s rest + 6x(16s left + 16s right) + 16s rest = 240s
%                       to localize LGN
%           - hrf     : color/luminance-defined checkerboard pattern 16s rest + 6x(16s stimulation + 16s rest) + 16s rest = 240s
%                       to measure HRF responses and to test scanner sequence
%           - localizer : color/luminance-defined checkerboard pattern 16s rest + 6x(16s stimulation + 16s compensating pattern) + 16s rest = 240s
%                       to identify specific eccentricity corresponding regions
%
%           *** task -- luminance change detection on the central fixation
%           - ccwf    : color/luminance-defined checkerboard wedge rotating counter-clockwisely
%           - cwf     : color/luminance-defined checkerboard wedge rotating clockwisely
%           - expf    : color/luminance-defined checkerboard annulus expanding from fovea
%           - contf   : color/luminance-defined checkerboard annulus contracting from periphery
%           - barf    : color/luminance-defined checkerboard bar, a standard pRF (population receptive field) stimulus
%           - ccwexpf : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
%           - ccwcontf: color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
%           - cwexpf  : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
%           - cwcontf : color/luminance-defined checkerboard wedge + annulus, a standard phase-encoded/pRF (population receptive field) stimulus
%           - multifocalf : color/luminance-defined checkerboard for a standard multifocal retinotopy stimulus
%           - meridianf : color/luminance-defined dual wedge checkerboard presented along the horizontal or vertical visual meridian
%           - lgnf    : color/luminance-defined checkerboard hemifield wedge pattern 16s rest + 6x(16s left + 16s right) + 16s rest = 240s
%                       to localize LGN
%           - hrff    : color/luminance-defined checkerboard pattern 16s rest + 6x(16s stimulation + 16s rest) + 16s rest = 240s
%                       to measure HRF responses and to test scanner sequence
%           - localizerf: color/luminance-defined checkerboard pattern 16s rest + 6x(16s stimulation + 16s compensating pattern) + 16s rest = 240s
%                       to identify specific eccentricity corresponding regions
%
%           *** these are stimulus windows to generate pRF (population receptive field) model
%           - ccwwindows     : stimulation windows of wedge rotating counter-clockwisely
%           - cwwindows      : stimulation windows of wedge rotating clockwisely
%           - expwindows     : stimulation windows of annulus expanding from fovea
%           - contwindows    : stimulation windows of annulus contracting from periphery
%           - barwindows     : stimulation windows of a standard pRF bar
%           - ccwexpwindows  : stimulation windows of a wedge+annulus checkerboard pattern
%           - ccwcontwindows : stimulation windows of a wedge+annulus checkerboard pattern
%           - cwexpwindows   : stimulation windows of a wedge+annulus checkerboard pattern
%           - cwcontwindows  : stimulation windows of a wedge+annulus checkerboard pattern
%           - multifocalwindows : stimulation windows of a standard multifocal retinotopy stimulus
%
%           string or a cell string structure, e.g. 'ccw', or {'ccw','exp'}
%           length(exp_mode) should equal numel(acq_num)
% acq_num : acquisition number, 1,2,3,...
%
% === NOTE: the two input variables below are only effective when exp_mode is set to *windows (one of stimulus window generation functions) ===
% overwrite_pix_per_deg : (optional) pixels-per-deg value to overwrite the sparam.pix_per_deg
%                 if not specified, sparam.pix_per_deg is used to reconstruct
%                 stim_windows.
%                 This is useful to reconstruct stim_windows with less memory space
%                 1/pix_per_deg = spatial resolution of the generated visual field,
%                 e.g. when pix_per_deg=20, then, 1 pixel = 0.05 deg.
%                 empty (use sparam.pix_per_deg) by default
% TR            : (optional) TR used in fMRI scans, in sec, 2 by default
%
% [output]
% OK      : (optional) flag, whether this script finished without any error [true/false]
%
%
% Created    : "2013-11-25 10:14:26 ban"
% Last Update: "2019-03-03 14:15:12 ban"


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check the input variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<3, help(mfilename()); return; end
if nargin<4 || isempty(overwrite_pix_per_deg), overwrite_pix_per_deg=[]; end
if nargin<5 || isempty(TR), TR=2; end

if size(exp_mode,1)==1 && ~iscell(exp_mode), exp_mode={exp_mode}; end
if ~isempty(find(acq_num<1,1)), error('acq_num should be 1,2,3,... check input variable'); end
if length(exp_mode)~=numel(acq_num), error('the numbers of exp_mode and acq_num mismatch. check input variable'); end

stimtypes={'ccw','cw','exp','cont','bar','ccwexp','cwexp','ccwcont','cwcont',...
           'ccwf','cwf','expf','contf','barf','ccwexpf','cwexpf','ccwcontf','cwcontf',...
           'multifocal','multifocalf','meridian','meridianf','hrf','hrff',...
           'localizer','localizerf','lgn','lgnf'};

windtypes={'ccwwindows','cwwindows','expwindows','contwindows','barwindows',...
           'ccwexpwindows','cwexpwindows','ccwcontwindows','cwcontwindows','multifocalwindows'};

for ii=1:1:length(exp_mode)
  if isempty(intersect(lower(exp_mode{ii}),stimtypes)) && isempty(intersect(lower(exp_mode{ii}),windtypes))
    % generating warning message like,
    %
    % exp_mode should be one of 'ccw', 'cw', 'exp', 'cont', 'bar', 'ccwexp', 'cwexp', 'ccwcont', 
    %                           'cwcont', 'ccwf', 'cwf', 'expf', 'contf', 'barf', 'ccwexpf', 'cwexpf', 
    %                           'ccwcontf', 'cwcontf', 'multifocal', 'multifocalf', 'meridian', 'meridianf', 'hrf', 'hrff', 
    %                           'localizer', 'localizerf', 'lgn', 'lgnf', 
    %                           'ccwwindows', 'cwwindows', 'expwindows', 'contwindows', 
    %                           'barwindows', 'ccwexpwindows', 'cwexpwindows', 'ccwcontwindows', 
    %                           'cwcontwindows', 'multifocalwindows'
    % check the input variables

    msg_str='exp_mode should be one of '; % 26 characters
    slen=length(msg_str);
    for pp=1:1:length(stimtypes)
      msg_str=[msg_str,'''',stimtypes{pp},''', '];
      if ~mod(pp,8), msg_str=[msg_str,'\n',repmat(' ',[1,slen])]; end
    end
    msg_str=[msg_str,'\n'];

    msg_str=[msg_str,repmat(' ',[1,slen])];
    for pp=1:1:length(windtypes)
      msg_str=[msg_str,'''',windtypes{pp},''', '];
      if ~mod(pp,4), msg_str=[msg_str,'\n',repmat(' ',[1,slen])]; end
    end
    msg_str=msg_str(1:end-2); % omit ', ' at the end of the string
    msg_str=[msg_str,'\ncheck the input variable\n'];

    fprintf(msg_str)

    if nargout, OK=false; end
    return
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
    run_fname{ii}='cretinotopy';            stim_mode{ii}='ccw';        stim_fname{ii}='c_pol';
  elseif strcmpi(exp_mode{ii},'cw')
    run_fname{ii}='cretinotopy';            stim_mode{ii}='cw';         stim_fname{ii}='c_pol';
  elseif strcmpi(exp_mode{ii},'exp')
    run_fname{ii}='cretinotopy';            stim_mode{ii}='exp';        stim_fname{ii}='c_ecc';
  elseif strcmpi(exp_mode{ii},'cont')
    run_fname{ii}='cretinotopy';            stim_mode{ii}='cont';       stim_fname{ii}='c_ecc';
  elseif strcmpi(exp_mode{ii},'bar')
    run_fname{ii}='cbar';                   stim_mode{ii}='bar';        stim_fname{ii}='c_bar';
  elseif strcmpi(exp_mode{ii},'ccwexp')
    run_fname{ii}='cdual';                  stim_mode{ii}='ccwexp';     stim_fname{ii}='c_dual';
  elseif strcmpi(exp_mode{ii},'cwexp')
    run_fname{ii}='cdual';                  stim_mode{ii}='cwexp';      stim_fname{ii}='c_dual';
  elseif strcmpi(exp_mode{ii},'ccwcont')
    run_fname{ii}='cdual';                  stim_mode{ii}='ccwcont';    stim_fname{ii}='c_dual';
  elseif strcmpi(exp_mode{ii},'cwcont')
    run_fname{ii}='cdual';                  stim_mode{ii}='cwcont';     stim_fname{ii}='c_dual';
  elseif strcmpi(exp_mode{ii},'multifocal')
    run_fname{ii}='cmultifocal';            stim_mode{ii}='multifocal'; stim_fname{ii}='c_multifocal';
  elseif strcmpi(exp_mode{ii},'meridian')
    run_fname{ii}='cmeridian';              stim_mode{ii}='meridian';   stim_fname{ii}='c_meridian';
  elseif strcmpi(exp_mode{ii},'lgn')
    run_fname{ii}='clgnlocalizer';          stim_mode{ii}='lgn';        stim_fname{ii}='c_lgnlocalizer';
  elseif strcmpi(exp_mode{ii},'hrf')
    run_fname{ii}='chrf';                   stim_mode{ii}='hrf';        stim_fname{ii}='c_hrf';
  elseif strcmpi(exp_mode{ii},'localizer')
    run_fname{ii}='clocalizer';             stim_mode{ii}='localizer';  stim_fname{ii}='c_localizer';
  elseif strcmpi(exp_mode{ii},'ccwf')
    run_fname{ii}='cretinotopy_fixtask';    stim_mode{ii}='ccw';        stim_fname{ii}='c_pol';
  elseif strcmpi(exp_mode{ii},'cwf')
    run_fname{ii}='cretinotopy_fixtask';    stim_mode{ii}='cw';         stim_fname{ii}='c_pol';
  elseif strcmpi(exp_mode{ii},'expf')
    run_fname{ii}='cretinotopy_fixtask';    stim_mode{ii}='exp';        stim_fname{ii}='c_ecc';
  elseif strcmpi(exp_mode{ii},'contf')
    run_fname{ii}='cretinotopy_fixtask';    stim_mode{ii}='cont';       stim_fname{ii}='c_ecc';
  elseif strcmpi(exp_mode{ii},'barf')
    run_fname{ii}='cbar_fixtask';           stim_mode{ii}='bar';        stim_fname{ii}='c_bar';
  elseif strcmpi(exp_mode{ii},'ccwexpf')
    run_fname{ii}='cdual_fixtask';          stim_mode{ii}='ccwexp';     stim_fname{ii}='c_dual';
  elseif strcmpi(exp_mode{ii},'cwexpf')
    run_fname{ii}='cdual_fixtask';          stim_mode{ii}='cwexp';      stim_fname{ii}='c_dual';
  elseif strcmpi(exp_mode{ii},'ccwcontf')
    run_fname{ii}='cdual_fixtask';          stim_mode{ii}='ccwcont';    stim_fname{ii}='c_dual';
  elseif strcmpi(exp_mode{ii},'cwcontf')
    run_fname{ii}='cdual_fixtask';          stim_mode{ii}='cwcont';     stim_fname{ii}='c_dual';
  elseif strcmpi(exp_mode{ii},'multifocalf')
    run_fname{ii}='cmultifocal_fixtask';    stim_mode{ii}='multifocal'; stim_fname{ii}='c_multifocal';
  elseif strcmpi(exp_mode{ii},'meridianf')
    run_fname{ii}='cmeridian_fixtask';      stim_mode{ii}='meridian';   stim_fname{ii}='c_meridian';
  elseif strcmpi(exp_mode{ii},'lgnf')
    run_fname{ii}='clgnlocalizer_fixtask';  stim_mode{ii}='lgn';        stim_fname{ii}='c_lgnlocalizer';
  elseif strcmpi(exp_mode{ii},'hrff')
    run_fname{ii}='chrf_fixtask';           stim_mode{ii}='hrf';        stim_fname{ii}='c_hrf';
  elseif strcmpi(exp_mode{ii},'localizerf')
    run_fname{ii}='clocalizer_fixtask';     stim_mode{ii}='localizer';  stim_fname{ii}='c_localizer';
  elseif strcmpi(exp_mode{ii},'ccwwindows')
    run_fname{ii}='gen_retinotopy_windows'; stim_mode{ii}='ccw';        stim_fname{ii}='c_pol';
  elseif strcmpi(exp_mode{ii},'cwwindows')
    run_fname{ii}='gen_retinotopy_windows'; stim_mode{ii}='cw';         stim_fname{ii}='c_pol';
  elseif strcmpi(exp_mode{ii},'expwindows')
    run_fname{ii}='gen_retinotopy_windows'; stim_mode{ii}='exp';        stim_fname{ii}='c_ecc';
  elseif strcmpi(exp_mode{ii},'contwindows')
    run_fname{ii}='gen_retinotopy_windows'; stim_mode{ii}='cont';       stim_fname{ii}='c_ecc';
  elseif strcmpi(exp_mode{ii},'barwindows')
    run_fname{ii}='gen_bar_windows';        stim_mode{ii}='bar';        stim_fname{ii}='c_bar';
  elseif strcmpi(exp_mode{ii},'ccwexpwindows')
    run_fname{ii}='gen_dual_windows';       stim_mode{ii}='ccwexp';     stim_fname{ii}='c_dual';
  elseif strcmpi(exp_mode{ii},'cwexpwindows')
    run_fname{ii}='gen_dual_windows';       stim_mode{ii}='cwexp';      stim_fname{ii}='c_dual';
  elseif strcmpi(exp_mode{ii},'ccwcontwindows')
    run_fname{ii}='gen_dual_windows';       stim_mode{ii}='ccwcont';    stim_fname{ii}='c_dual';
  elseif strcmpi(exp_mode{ii},'cwcontwindows')
    run_fname{ii}='gen_dual_windows';       stim_mode{ii}='cwcont';     stim_fname{ii}='c_dual';
  elseif strcmpi(exp_mode{ii},'multifocalwindows')
    run_fname{ii}='gen_multifocal_windows'; stim_mode{ii}='multifocal'; stim_fname{ii}='c_multifocal';
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check whether the subject directory already exists
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [NOTE]
% if the subj directory is not found, the directory is created with coping
% all condition files from DEFAULT and then this function tries to run the
% stimulus presentation script using the DEFAULT parameters

subj_dir=fullfile(fileparts(mfilename('fullpath')),'subjects',subj);
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
  if ~isempty(intersect(lower(exp_mode{ii}),windtypes)) % generate stimulus windows
    main_exp_name=sprintf('%s(''%s'',''%s'',%d,''%s'',''%s'',%d,%d);',...
        run_fname{ii},subj,stim_mode{ii},acq_num(ii),disp_fname,stim_fname{ii},overwrite_pix_per_deg,TR);
  else % stimulus presentation
    main_exp_name=sprintf('%s(''%s'',''%s'',%d,''%s'',''%s'',gammatable);',...
        run_fname{ii},subj,stim_mode{ii},acq_num(ii),disp_fname,stim_fname{ii});
  end
  eval(main_exp_name);
end

if nargout, OK=true; end

return
