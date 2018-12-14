function structval=ValidateStructureFields(structval,varargin)

% Validates the input structure and set the default values to the missing field(s)
% function structval=ValidateStructureFields(structval,varargin)
%
% [about]
% This function validates the input structure, structval, and set the default values
% to the missing field(s).
% For instance, if you run the codes below,
% >> dparam=struct(); % initialize
% >> if ~isempty(displayfile) % displayfile contains specific fields (dparam.*), and they are loaded onto memory
% >>   run(fullfile(rootDir,'subjects',subjID,displayfile));
% >> end
% >> dparam=ValidateStructureFields(dparam,... % validate fields and set the default values to missing field(s)
% >>          'ExpMode','shutter',...
% >>          'start_method',1,...
% >>          'custom_trigger',KbName(84),...
% >>          'Key1',37,...
% >>          'Key2',39,...
% >>          'givefeedback',1,...
% >>          'fullscr',false,...
% >>          'ScrHeight',1200,...
% >>          'ScrWidth',1920);
%
% The procedures below are evaluated.
% 1.'dparam' structure is initialized as empty at the begnning.
% 2. the specific fileds and values are set at the socond-fourth lines.
% 3. the 'dparam' structure is validated and set the default values to the missing field(s) with this function.
% If some fields are already configured by user, this function never overwrites them.
%
% [input]
% structval : a structure to be validated. structval=struct(); by default.
%
% From the second input variables, please set as
% 'fieldname1',default_value(s),'fieldname2',default_value(s),'fieldname3',default_value(s),...
% Therefore, the total number of input variables should be 1 (structval) + 2*N (N=the number of fields to be set to structval).
%
% [output]
% structval : structure with full fields you want.
%
%
% Created    : "2018-11-11 21:38:52 ban"
% Last Update: "2018-11-11 22:03:36 ban"

% check the input variable
if nargin<1, help(mfilename()); return; end
if mod(nargin,2)==0
  % here, %s is required as error can not recoginize cadge return (e.g. \n) unless it has more than 1 input variables.
  error(['the total number of input variables should be\n',...
         '1 (structval) + 2 (name and default value(s)) * N (N=the number of fields to be set to structval).\n',...
         'check the input variables%s'],'.');
end

% loop for the fields with validating the 
for ii=1:2:nargin-1
  if isstructmember(structval,varargin{ii})
    if isempty(getfield(structval,varargin{ii}))
      structval=setfield(structval,varargin{ii},varargin{ii+1});
    end
  else
    structval=setfield(structval,varargin{ii},varargin{ii+1});
  end
end

return
