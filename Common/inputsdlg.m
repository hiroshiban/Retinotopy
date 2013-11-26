function [Answer,Canceled] = inputsdlg(Prompt, Title, Formats, DefAns, Options)
% INPUTSDLG Enhanced input dialog box supporting multiple data types
% ANSWER = INPUTSDLG(PROMPT) creates a modal dialog box that returns user
% input for multiple prompts in the cell array ANSWER. PROMPT is a 1-D
% cell array containing the PROMPT strings.
%
% Alternatively, PROMPT can be a two-column cell array where the prompt
% string is supplied in the first column. Output ANSWER of the function is
% then in a structure with the field names defined in the second column of
% the PROMPT cell array.
%
% Moreover, PROMPT may have three columns, where the third column gives
% units (i.e., post-fix labels to the right of controls) to display.
%
% INPUTSDLG uses UIWAIT to suspend execution until the user responds.
%
% ANSWER = INPUTSDLG(PROMPT,NAME) specifies the title for the dialog.
%
% Note that INPUTSDLG(PROMPT) & INPUTSDLG(PROMPT,NAME) are similar to the
% standard INPUTDLG function, except for the dialog layout.
%
% ANSWER = INPUTSDLG(PROMPT,NAME,FORMATS) can be used to specify the type
% of parameters to display with FORMATS matrix of structures. The
% dimension of FORMATS defines how PROMPT items are laid out in the dialog
% box. For example, if PROMPT has 6 elements and the size of FORMATS is
% 2x3 then, the items are shown in 2 rows, 3 columns format.
% The items in PROMPT correspond to a column-first traversal of FORMATS.
%
% The fields in FORMATS structure are:
%
%   type   - Type of control ['check',{'edit'},'list','range','text','none']
%   style  - UI control type used. One of:
%            [{'checkbox'},       for 'check' type
%             {'edit'}            for 'edit' type
%              'listbox',{'popupmenu'},'radiobutton','togglebutton'
%                                 for 'list' type
%             {'slider'}          for 'range' type
%             {'text'}]           for 'text' type
%   items  - Selection items for 'list' type (cell of strings)
%   format - Data format: ['string','date','float','integer','file','dir']
%   limits - [min max] (see below for details)
%   size   - [width height] in pixels. Alternatively, 0 to auto-size or -1
%            to auto-expand when figure is resized.
%   enable - Defines how to respond to mouse button clicks, including which
%            callback routines execute. One of:
%            [{'on'}      - UI control is operational.
%              'inactive' EUI control is not operational, but looks the
%                           same as when Enable is on.
%              'off'      EUI uicontrol is not operational and its image
%                           is grayed out.
%
% FORMATS type field defines what type of prompt item to be shown.
%
%   type  Description
%   -------------------------------------------------------------------
%   edit  Standard edit box (single or multi-line mode)
%   check Check box for boolean item
%   list  Chose from a list of items ('listbox' style allows multiple item
%         selection)
%   range Use slider to chose a value over a range
%   text  Static text (e.g., for instructions)
%   none  A placeholder. May be used for its neighboring item to extend
%         over multiple columns or rows (i.e., "to merge cells")
%
% The allowed data format depends on the type of the field:
%
%   type    allowed format
%   --------------------------------------------
%   check   integer
%   edit    {text}, date, float, integer, file, dir
%   list    integer
%   range   float
%
% By leaving format field empty, a proper format is automatically chosen
% (or default to text format for edit type).
%
% Formats 'file' and 'dir' for 'edit' type uses the standard UIGETFILE,
% UIPUTFILE, and UIGETDIR functions to retrieve a file or directory name.
%
% The role of limits field varies depending on other parameters:
%
%   style         role of limits
%   ---------------------------------------------------
%   checkbox      limits(1) is the ANSWER value if the check box is not
%                 selected  box is not selected and limits(2) is the ANSWER
%                 if the check box is selected.
%   edit (text format)
%                 If diff(limits)>1, multi-line mode; else, single-line
%                 mode
%   edit (date format)
%                 limits must be a free-format date format string
%                 or a scalar value specifying the date format.
%                 Supported format numbers are: 0,1,2,6,13,14,15,16,23.
%                 The default date format is 0 ('dd-mmm-yyyy HH:MM:SS').
%                 See the tables in DATESTR help for the format definitions.
%                 As long as the user entry is a valid date/time
%                 expression, the dialog box automatically converts to the
%                 assigned format.
%   edit (numeric format)
%                 This style defines the range of allowed values
%   edit (file format)
%                 If 0<=diff(limits)<=1 uses UIGETFILE in single select
%                 mode with single-line edit. If diff(limits)>1 uses
%                 UIGETFILE in multi-select mode with multi-line edit. If
%                 diff(limits)<0 usees UIPUTFILE with single- line edit
%   listbox       If diff(limits)>1, multiple items can be selected. If
%                 limits(1)>0, a maximum of limits(1) lines will be shown.
%   slider        limits(1) defines the smallest value while
%                 limits(2) defines the largest value
%   none          If diff(limits)==0 space is left empty
%                 If diff(limits)>0 : lets the item from left to extend
%                 If diff(limits)<0 : lets the item from above to extend
%
% Similar to how PROMPT strings are laid out, when FORMATS.style is set to
% either 'radiobutton' or 'togglebutton', FORMATS.items are laid out
% according to the dimension of FORMATS.items.
%
% There are two quick format options as well:
%
%  Quick Format Option 1 (mimicing INPUTDLG behavior):
%   FORMATS can specify the number of lines for each edit-type prompt in
%   FORMATS. FORMATS may be a constant value or a column vector having
%   one element per PROMPT that specifies how many lines per input field.
%   FORMATS may also be a matrix where the first column specifies how
%   many rows for the input field and the second column specifies how
%   many columns wide the input field should be.
%
%  Quick Format Option 2:
%   FORMATS can specify the types of controls and use their default
%   configurations. This option, however, cannot be used to specify
%   'list' control as its items are not specified. To use this option,
%   provide a string (if only 1 control) or a cell array of strings. If
%   a cell array is given, its dimension is used for the dialog
%   layout.
%
% ANSWER = INPUTSDLG(PROMPT,NAME,FORMATS,DEFAULTANSWER) specifies the
% default answer to display for each PROMPT. DEFAULTANSWER must contain
% the same number of elements as PROMPT (that are not of 'none' style). If
% PROMPT does not provide ANSWER structure fields, DEFAULTANSWER should be
% a cell array with element type corresponding to FORMATS.format. Leave the
% cell element empty for a prompt with 'text' type. If ANSWER is a
% structure, DEFAULTANSWER must be a structure with the specified fields.
% (If additional fields are present in DEFAULTANSWER, they will be returned
% as parts of ANSWER.)
%
% For edit::file controls, a default answer that does not correspond to an
% existing file will be used as a default path and/or file name in the
% browse window.  It is passed as the DefaultName parameter to UIGETFILE or
% UIPUTFILE.
%
% ANSWER = INPUTSDLG(PROMPT,NAME,FORMATS,DEFAULTANSWER,OPTIONS) specifies
% additional options. If OPTIONS is the string 'on', the dialog is made
% resizable. If OPTIONS is a structure, the fields recognized are:
%
%  Option Field Description {} indicates the default value
%  ----------------------------------------------------------------------
%  Resize        Make dialog resizable: 'on' | {'off'}
%  WindowStyle   Sets dialog window style: {'normal'} | 'modal'
%  Interpreter   Label text interpreter: 'latex' | {'tex'} | 'none'
%  CancelButton  Show Cancel button: {'on'} | 'off'
%  ApplyButton   Adds Apply button: 'on' | {'off'}
%  Sep           Space b/w prompts in pixels: {10}
%  ButtonNames   Customize OK|Cancel|Apply button names: {up to 3 elements}
%  AlignControls Align adjacent controls in the same column: 'on' | {'off'}
%  UnitsMargin   Space between each control and its unit text in pixels: {5}
%
% [ANSWER,CANCELED] = INPUTSDLG(...) returns CANCELED = TRUE if user
% pressed Cancel button, closed the dialog, or pressed ESC. In such event,
% the content of ANSWER is set to the default values.
%
% Note on Apply Button feature. Pressing the Apply button makes the current
% change permanent. That is, pressing Cancel button after pressing Apply
% button only reverts ANSWER back to the states when the Apply button was
% pressed last. Also, if user pressed Apply button, CANCELED flag will not
% be set even if user canceled out of the dialog box.
%
% Examples:
%
% prompt={'Enter the matrix size for x^2:';'Enter the colormap name:'};
% name='Input for Peaks function';
% formats(1) = struct('type','edit','format','integer','limits',[1 inf]);
% formats(2) = struct('type','edit','format','text','limits',[0 1]);
% defaultanswer={20,'hsv'};
%
% [answer,canceled] = inputsdlg(prompt,name,formats,defaultanswer);
%
% formats(2).size = -1; % auto-expand width and auto-set height
% options.Resize='on';
% options.WindowStyle='normal';
% options.Interpreter='tex';
%
% answer = inputsdlg(prompt,name,formats,defaultanswer,options);
%
% prompt(:,2) = {'Ndim';'Cmap'};
% defaultanswer = struct(defaultanswer,prompt(:,2),1);
%
% answer = inputsdlg(prompt,name,formats,defaultanswer,options);
%
% See also INPUTDLG, DIALOG, ERRORDLG, HELPDLG, LISTDLG, MSGBOX,
%  QUESTDLG, TEXTWRAP, UIWAIT, WARNDLG, UIGETFILE, UIPUTFILE, UIGETDIR,
%  DATESTR.

% Version 1.3 (August 13, 2010)
% Written by: Takeshi Ikuma
% Contributors: Andreas Greuer, Luke Reisner
% Created: Nov. 16, 2009
% Revision History:
%  v.1.1 (Nov. 19, 2009)
%  * Fixed bugs (reported by AG):
%   - not returning Canceled output
%   - erroneous struct output behavior
%   - error if all row elements of a column are auto-expandable
%  * Added Apply button option
%  * Added support for Units (label to the right of controls)
%  * Updated the help text
%  v.1.11 (Nov. 20, 2009)
%  * Fixed bugs (reported by AG):
%   - incorrect Canceled output when Cancel button is pressed
%  v.1.12 (Nov. 20, 2009)
%  * Fixed bugs (reported by AG):
%   - again incorrect Canceled output behavior
%  v.1.2 (May 20, 2010)
%  * Fixed bugs (reported by AG & Jason):
%   - Apply button->Canel button does not revert back to post-apply answers.
%   - Line 265 handles.Figure -> handles.fig
%  * Added edit::date support
%  * Added formats.enable support
%  * Added options.CancelButton support
%  * Added options.ButtonNames support
%  v.1.2.1 (June 11, 2010)
%  * Fixed default option bug (reported by Jason)
%  v.1.2.2 (July 15, 2010)
%  * Rewritten checkoptions() (to correct issues reported by Jason)
%  * Bug Fix: file & dir control enable config were interpreted backwards
%  v.1.2.3 (July 19, 2010)
%  * checkoptions() bug fix (to correct issues reported by Kevin)
%  v.1.3 (August 13, 2010, by Luke Reisner)
%  * Improved dialog layout:
%   - Less wasted space, better control distribution, more consistent margins
%   - Buttons are right-aligned per OS standards
%  * Changed edit::date to return a simple date vector (see DATEVEC help)
%  * Added support for free-form date format specifiers to edit::date
%  * Added ability to limit the number of displayed lines for a listbox
%  * Added ability to set default browse path/filename for edit::file controls
%  * Added options.AlignControls to align adjacent controls in the same column
%  * Added options.UnitsMargin to control spacing between controls and units
%  * Fixed bugs:
%   - Flickering or misplaced controls when dialog first appears
%   - Radiobutton and togglebutton controls couldn't be disabled
%   - Edit::integer controls allowed non-integer values
%   - Slider controls didn't auto-size properly
%   - Other minor miscellaneous bugs

%%%%%%%%%%%%%%%%%%%%
%%% Nargin Check %%%
%%%%%%%%%%%%%%%%%%%%
error(nargchk(0,5,nargin));
error(nargoutchk(0,2,nargout));

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Handle Input Args %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<1, Prompt=''; end
if nargin<2, Title = ''; end
if nargin<3, Formats=struct([]); end
if nargin<4, DefAns = {}; end
if nargin<5, Options = struct([]); end

% Check Prompt input
[Prompt,FieldNames,Units,err] = checkprompt(Prompt);
if ~isempty(err), error(err{:}); end
NumQuest = numel(Prompt); % number of prompts

if isempty(Title)
   Title = ' ';
elseif iscellstr(Title)
   Title = Title{1}; % take the first entry
elseif ~ischar(Title)
   error('inputsdlg:InvalidInput','Title must be a string of cell string.');
end

% make sure that the Formats structure is valid & fill it in default
% values as needed
[Formats,err] = checkformats(Formats,NumQuest);
if ~isempty(err), error(err{:}); end

% make sure that the DefAns is valid & set Answer using DefAns and default
% values if DefAns not given
[Answer,AnsStr,err] = checkdefaults(DefAns,Formats,FieldNames);
if ~isempty(err), error(err{:}); end

% make sure that the Options is valid
[Options,err] = checkoptions(Options);
if ~isempty(err), error(err{:}); end

Applied = false; % set true by pressing Apply Button
Resized = 0;  % Used to ensure doResize() is called exactly once during initialization

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Create Dialog GUI %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
% lay contents out on a dialog box
[handles,Formats,sinfo] = buildgui(Prompt,Units,Title,Formats,Options);

% set default values
for k = 1:NumQuest
   switch Formats(k).style
      case {'checkbox' 'listbox' 'popupmenu' 'slider'}
         set(handles.ctrl(k),'Value',Answer{k});
      case 'edit'
         if any(strcmp(Formats(k).format,{'integer','float'}))
            set(handles.ctrl(k),'String',num2str(Answer{k}));
         elseif strcmp(Formats(k).format, 'file')
            file_list = cellstr(Answer{k});
            if (diff(Formats(k).limits) >= 0) % Control associated with uigetfile()
               if (length(file_list) == 1) && ((exist(file_list{1}, 'file') ~= 2) || isempty(fileparts(file_list{1})))
               % There is one file argument that either is not an existing file or lacks a path
                  h = get(handles.ctrl(k),'UserData');
                  h{1} = file_list{1};  % Use the argument as the DefaultName parameter but not the default answer
                  set(handles.ctrl(k),'String','','UserData',h);
               else
                  set(handles.ctrl(k),'String',Answer{k});  % Use the file(s) as the default answer
                  if (diff(Formats(k).limits) >= 2) && ~isempty(file_list) && ~isempty(file_list{1})
                  % The control is associated with a multi-file uigetfile() and has default filename(s)
                     % Store the path/file names in UserData
                     h = get(handles.ctrl(k),'UserData');
                     h{1} = fileparts(file_list{1});  % Store the (already verified) common path
                     for file_index = 1 : length(file_list)
                        [file_path, file_partial_name, file_extension] = fileparts(file_list{file_index}); %#ok
                        h{2}{file_index} = [file_partial_name, file_extension];  % Store the file name
                     end
                     set(handles.ctrl(k),'UserData',h);
                  end
               end
            else % Control associated with uiputfile()
               if isdir(file_list{1}) || isempty(fileparts(file_list{1}))  % One file argument specifying a directory or lacking a path
                  h = get(handles.ctrl(k),'UserData');
                  h{1} = file_list{1};  % Use the argument as the DefaultName parameter but not the default answer
                  set(handles.ctrl(k),'String','','UserData',h);
               else
                  set(handles.ctrl(k),'String',Answer{k});  % Use the file as the default answer
               end
            end
         else % if {'text','date','dir'}
            set(handles.ctrl(k),'String',Answer{k});
         end
      case {'radiobutton' 'togglebutton'}
         h = get(handles.ctrl(k),'UserData');
         set(handles.ctrl(k),'SelectedObject',h(Answer{k}));
   end
end

% Set callback functions and 'Enable' states
for k = 1:NumQuest % for all non-'text' controls
   if strcmp(Formats(k).style,'edit')
      switch Formats(k).format
         case 'date'
            set(handles.ctrl(k),'Callback',@(hObj,evd)checkDate(hObj,evd,k,Formats(k).limits),...
               'Enable',Formats(k).enable);
         case {'float','integer'}
            % for numeric edit box, check for the range & set mouse down behavior
            set(handles.ctrl(k),'Callback',@(hObj,evd)checkRange(hObj,evd,k,Formats(k).limits),...
               'Enable',Formats(k).enable);
         case 'file'
            if strcmp(Formats(k).enable,'on')
               ena = 'inactive';
               mode = diff(Formats(k).limits);
               fcn = @(hObj,evd)openFilePrompt(hObj,evd,Formats(k).items,Prompt{k},mode);
            else
               ena = Formats(k).enable;
               fcn = {};
            end
            set(handles.ctrl(k),'ButtonDownFcn',fcn,'Enable',ena);
         case 'dir'
            if strcmp(Formats(k).enable,'on')
               ena = 'inactive';
               fcn = @(hObj,evd)openDirPrompt(hObj,evd,Prompt{k});
            else
               ena = Formats(k).enable;
               fcn = {};
            end
            set(handles.ctrl(k),'ButtonDownFcn',fcn,'Enable',ena);
         otherwise
            set(handles.ctrl(k),'Enable',Formats(k).enable);
      end
   elseif any(strcmp(Formats(k).style, {'radiobutton', 'togglebutton'}))
      button_handles = get(handles.ctrl(k), 'UserData');  % Disable the child buttons instead of the uibuttongroup container
      valid_indexes = (button_handles ~= 0);
      set(button_handles(valid_indexes), 'Enable', Formats(k).enable);
   elseif ~strcmp(Formats(k).style, 'text')
      set(handles.ctrl(k), 'Enable', Formats(k).enable);
   end
end

set(handles.fig, 'UserData', 'Cancel');
for k = 1 : numel(handles.btns)
   switch get(handles.btns(k), 'UserData')
      case 'OK'
         set(handles.btns(k), 'KeyPressFcn', @(hObj,evd)doControlKeyPress(hObj,evd,true), 'Callback', @(hObj,evd)doCallback(hObj,evd,true));
      case 'Cancel'
         set(handles.btns(k), 'KeyPressFcn', @(hObj,evd)doControlKeyPress(hObj,evd,false), 'Callback', @(hObj,evd)doCallback(hObj,evd,false));
      case 'Apply'
         set(handles.btns(k), 'KeyPressFcn', @(hObj,evd)doControlKeyPress(hObj,evd), 'Callback', @doApply);
   end
end
set(handles.fig, 'KeyPressFcn', @doFigureKeyPress, 'ResizeFcn', @doResize);

% make sure we are on screen
movegui(handles.fig)

% if there is a figure out there and it's modal, we need to be modal too
if ~isempty(gcbf) && strcmp(get(gcbf,'WindowStyle'),'modal')
   set(handles.fig,'WindowStyle','modal');
end

% ready to begin the show!
if (Resized == 0)  % In some Matlab configurations, doResize() may not have been called yet
   doResize(handles.fig);  % Ensure the GUI controls are put in their proper places
end
set(handles.fig,'Visible','on');
drawnow;
Resized = 2;  % Initialization complete; allow all future calls to doResize()

% set focus on the first uicontol
h = handles.ctrl(find(~strcmp('text',{Formats.type}),1,'first'));
if ~isempty(h)
   switch get(h,'type')
      case 'uicontrol', uicontrol(h);
      case 'uitoggletool', uicontrol(get(h,'SelectedObject'));
   end
end

% Go into uiwait if the figure handle is still valid.
% This is mostly the case during regular use.
if ishghandle(handles.fig), uiwait(handles.fig); end

% Check handle validity again since we may be out of uiwait because the
% figure was deleted.
Canceled = ~(ishghandle(handles.fig) && strcmp(get(handles.fig,'UserData'),'OK'));
if Canceled % return the default answer
   if isempty(FieldNames), Answer = DefAns;
   else Answer = AnsStr; end % AnsStr contains the default value until getAnswer is called
else
   Answer = getAnswer(Answer,AnsStr); % get the final answers
end

Canceled = Canceled && ~Applied;

% Close the figure if it's still open
if ishghandle(handles.fig), delete(handles.fig); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% NESTED FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   function answer = getAnswer(answer,ansstr)
      % retrieve answer from controls
      for i = 1:numel(answer)
         switch Formats(i).style
            case {'checkbox' 'listbox' 'popupmenu' 'slider'}
               answer{i} = get(handles.ctrl(i),'Value');
            case 'edit'
               switch Formats(i).format
                  case {'text' 'dir'}
                     answer{i} = get(handles.ctrl(i),'String');
                  case 'date'
                     date_string = get(handles.ctrl(i), 'String');
                     if isempty(date_string)
                        answer{i} = [];  % Return an empty date vector if no date was entered
                     else
                        answer{i} = datevec(date_string, Formats(i).limits);
                     end
                  case 'file'
                     data = get(handles.ctrl(i),'UserData');
                     if (length(data) == 1)  % Single-file selection
                        answer{i} = get(handles.ctrl(i),'String');
                     else % multi-select
                        if isempty(data{2})  % No files were selected
                           answer{i} = {};
                        else
                           answer{i} = strcat(data{1}, cellstr(data{2}));
                        end
                     end
                  otherwise
                     answer{i} = str2double(get(handles.ctrl(i),'String'));
               end
            case {'radiobutton' 'togglebutton'}
               answer{i} = find(get(handles.ctrl(i),'SelectedObject')==get(handles.ctrl(i),'UserData'));
         end
      end
      
      % if struct answer expected, copy
      if ~isempty(FieldNames)
         idx = find(~cellfun('isempty',FieldNames))';
         for i = idx
            ansstr.(FieldNames{i}) = answer{i};
         end
         answer = ansstr;
      end
   end

   function doApply(hObj,evd) %#ok
      Applied = true; % set the flag
      DefAns = getAnswer(Answer,AnsStr);
      if isstruct(DefAns)
         AnsStr = DefAns;
         DefAns = cell(size(FieldNames));
         idx = find(~cellfun('isempty',FieldNames))';
         for i = idx
            DefAns{i} = AnsStr.(FieldNames{i});
         end
      end
   end

   function checkRange(hObj,evd,k,lim) %#ok
      val = str2double(get(hObj,'String'));
      if strcmp(Formats(k).format, 'integer')
         val = round(val);  % Round to the nearest integer
      end
      if ~isnan(val) && val>=lim(1) && val<=lim(2)
         Answer{k} = val;
         set(hObj, 'String', num2str(Answer{k}));  % If necessary, eliminates spaces or changes to the rounded integer
      else
         if strcmp(Formats(k).format,'integer')
            msg = sprintf('%d, %d',lim(1),lim(2));
         else
            msg = sprintf('%g, %g',lim(1),lim(2));
         end
         h = errordlg(sprintf('This parameter must be within the range [%s].',msg),'Invalid Value','modal');
         uiwait(h);
         set(hObj,'String',num2str(Answer{k}));
      end
   end

   function checkDate(hObj,evd,k,format) %#ok
      str = get(hObj,'string');
      if isempty(str)  % Avoid calling datenum() which prints a warning for empty strings
         Answer{k} = '';
         set(hObj, 'String', Answer{k});
         return;
      end
      try
         num = datenum(str, format);  % Check if the input matches the custom date format first
      catch  %#ok
         try
            num = datenum(str);  % Check if the input matches any other supported date format
         catch  %#ok
            h = errordlg(sprintf('Unsupported date format.'),'Invalid Value','modal');
            uiwait(h);
            set(hObj,'String',Answer{k});
            return;
         end
      end
      Answer{k} = datestr(num,format);
      set(hObj,'String',Answer{k});
   end

   function doFigureKeyPress(obj, evd)
      switch(evd.Key)
         case {'return','space'}
            set(obj,'UserData','OK');
            uiresume(obj);
         case {'escape'}
            delete(obj);
      end
   end

   function doControlKeyPress(obj, evd, varargin)
      switch(evd.Key)
         case {'return'} % execute its callback function with varargin
            cbfcn = get(obj,'Callback');
            cbfcn(obj,evd);
         case 'escape'
            delete(gcbf)
      end
   end

   function doCallback(obj, evd, isok) %#ok
      if isok || Applied
         if isok, set(gcbf,'UserData','OK'); end
         uiresume(gcbf);
      else
         delete(gcbf)
      end
   end

   function openFilePrompt(hObj,evd,spec,prompt,mode) %#ok
      
      if mode<0 % uiputfile
         if isempty(get(hObj,'String'))  % No file is selected yet
            data = get(hObj,'UserData');  % Get the DefaultName parameter from the UserData
            [f,p] = uiputfile(spec,prompt,data{1});
         else  % A file is already selected
            [f,p] = uiputfile(spec,prompt,get(hObj,'String'));
         end
         if f~=0, set(hObj,'String',[p f]); end
      elseif mode<=1 % uigetfile, single-select
         if isempty(get(hObj,'String'))  % No file is selected yet
            data = get(hObj,'UserData');  % Get the DefaultName parameter from the UserData
            [f,p] = uigetfile(spec,prompt,data{1});
         else  % A file is already selected
            [f,p] = uigetfile(spec,prompt,get(hObj,'String'));
         end
         if f~=0, set(hObj,'String',[p f]); end
      else % uigetfile multi-select
         % previously chosen files are lost, but directory is kept
         data = get(hObj,'UserData');
         [f,p] = uigetfile(spec,prompt,data{1},'MultiSelect','on');
         if p~=0
            data = {p f};
            if ischar(f) % single file selected
               set(hObj,'String',[p f],'UserData',data);
            else % multiple files selected
               str = sprintf('%s%s',p,f{1});
               for n = 2:length(f)
                  str = sprintf('%s\n%s%s',str,p,f{n});
               end
               set(hObj,'String',str,'UserData',data);
            end
         end
      end
      uicontrol(hObj);
   end

   function openDirPrompt(hObj,evd,prompt) %#ok
      p = uigetdir(get(hObj,'String'),prompt);
      if p~=0, set(hObj,'String',p); end
      uicontrol(hObj);
   end

   function doResize(hObj,evd) %#ok
      % This function places all controls in proper place.
      % Must be called before the GUI is made visible as buildgui function
      % just creates uicontrols and do not place them in proper places.
      
      % Ensure doResize() is called exactly once during initialization
      switch Resized
         case 0  % Not resized yet
            Resized = 1;
         case 1  % Still initializing, and initial resize has already occurred
            return;
         % otherwise allow resizing because initialization is complete
      end
      
      % get current figure size
      figPos = get(hObj,'Position');
      figSize = figPos(3:4);
      
      % determine the column width & row heights
      workarea = [Options.Sep Options.Sep figSize - 2*Options.Sep]; % Options.Sep margins around the figure
      btnarea = [0,0,workarea(3),sinfo.h_btns];
      ctrlarea = [0,btnarea(4)+Options.Sep,workarea(3),workarea(4)-sinfo.h_btns-Options.Sep];
      
      dim = size(sinfo.map);
      num = numel(handles.ctrl);
      
      % determine the column widths & margin
      w = sinfo.w_ctrls+sinfo.w_labels+sinfo.w_units; % minimum widths of elements
      width = zeros(size(sinfo.map));
      cext = false(1,dim(2));
      for n = 1:dim(2)
         cmap = sinfo.map(:,n);
         cext(n) = any(sinfo.autoextend(cmap(cmap~=0),1));
      end
      if any(cext) % found auto-extendable element(s)
         m_col = Options.Sep; % column margin fixed
         w_total = ctrlarea(3)-(dim(2)-1)*m_col;
         
         % record the widths of non-expandable elements
         for n = find(~sinfo.autoextend(:,1))'
            idx = find(sinfo.map==n);
            [i,j] = ind2sub(dim,idx); %#ok
            J = unique(j);
            n_col = numel(J);
            if (n_col == 1)
               width(idx) = w(n);
            end
         end
         width = distribute_spanned_controls(sinfo.map, width, [], w, [], sinfo.autoextend, m_col);
         w_col = max(width,[],1); % column width based on non-expandables
         
         % figure out how to distribute extra spaces among auto-expandable columns
         w_avail = w_total - sum(w_col(~cext)); % available width
         idx = w_col(cext)==0; % column where all elements are auto-expandable
         if all(idx) % all columns auto-expandable
            w_col(cext) = w_avail/sum(cext); % equally distributed
         else
            w_xcol = w_col(cext);
            if any(idx)
               w_xcol(idx) = mean(w_xcol(~idx));
            end % some columns are auto-expandable
            w_xcol = w_xcol + (w_avail-sum(w_xcol))/sum(cext); % equally distribute the excess
            w_col(cext) = w_xcol;
         end
         
         w_col = max(w_col,1); % make sure it's positive
         
         % set the expandable controls' width
         for n = find(sinfo.autoextend(:,1))'
            idx = find(sinfo.map==n);
            [i,j] = ind2sub(dim,idx); %#ok
            J = unique(j);
            if strcmp(Formats(n).type,'text')
               sinfo.w_labels(n) = sum(w_col(J));
            else
               sinfo.w_ctrls(n) = max(sum(w_col(J)) - sinfo.w_labels(n) - sinfo.w_units(n), 1);
            end
         end
      else % no auto-extension, adjust column margin
         for n = 1:num
            idx = find(sinfo.map==n);
            [i,j] = ind2sub(dim,idx); %#ok
            J = unique(j);
            n_col = numel(J);
            if (n_col == 1)
               width(idx) = w(n);
            end
         end
         width = distribute_spanned_controls(sinfo.map, width, [], w, [], [], Options.Sep);
         w_col = max(width,[],1);
         if (dim(2) == 1)
            m_col = 0;  % No margins for a single column
         else
            m_col = (ctrlarea(3)-sum(w_col))/(dim(2)-1);
         end
      end
      
      % resize static text with auto-height
      aex = sinfo.autoextend;
      for m = find(strcmp('text',{Formats.type}) & any(sinfo.autoextend(:,2)))
         idx = find(sinfo.map==m);
         [i,j] = ind2sub(dim,idx); %#ok
         J = unique(j);
         w = sum(w_col(J)) + (numel(J)-1)*m_col;
         if w<=100, w = 100; end
         
         % create dummy uicontrol to wrap text
         h = uicontrol('Parent',hObj,'Style','text','Position',[0 0 w 20],'Visible','off');
         msg = textwrap(h,Prompt(m));
         delete(h);
         str = msg{1};
         for n = 2:length(msg)
            str = sprintf('%s\n%s',str,msg{n});
         end
         
         % update the text wrapping
         set(handles.labels(m),'String',str);
         
         % get updated size
         pos = get(handles.labels(m),'Extent');
         sinfo.w_labels(m) = pos(3);
         sinfo.h_labels(m) = pos(4);
         sinfo.h_ctrls(m) = pos(4);
         
         aex(m,2) = false;
      end
      
      % determine the row heights & margin
      h = max([sinfo.h_ctrls,sinfo.h_labels,sinfo.h_units],[],2);
      height = zeros(size(sinfo.map));
      rext = false(dim(1),1);
      for n = 1:dim(1)
         cmap = sinfo.map(n,:);
         rext(n) = any(aex(cmap(cmap~=0),2));
      end
      if any(rext)
         m_row = Options.Sep; % column margin fixed
         h_total = ctrlarea(4)-(dim(1)-1)*m_row; % sum of control width
         
         % record the heights of non-expandable elements
         for n = find(~aex(:,2))'
            idx = find(sinfo.map==n);
            [i,j] = ind2sub(dim,idx); %#ok
            I = unique(i);
            n_row = numel(I);
            if (n_row == 1)
               height(idx) = h(n);
            end
         end
         [temp, height] = distribute_spanned_controls(sinfo.map, [], height, [], h, aex, m_row); %#ok
         h_row = max(height,[],2); % column width based on non-expandables
         
         % figure out how to distribute extra spaces among auto-expandable rows
         h_avail = h_total - sum(h_row(~rext)); % available width
         idx = h_row(rext)==0; % column where all elements are auto-expandable
         if all(idx) % all columns auto-expandable
            h_row(rext) = h_avail/sum(rext); % equally distributed
         else
            h_xrow = h_row(rext);
            if any(idx), h_xrow(idx) = mean(h_xrow(~idx)); end % some columns are auto-expandable
            h_xrow = h_xrow + (h_avail-sum(h_xrow))/sum(rext); % equally distribute the excess
            h_row(rext) = h_xrow;
         end
         
         h_row = max(h_row,1);
         
         % set the expandable controls height
         for n = find(aex(:,2))'
            idx = find(sinfo.map==n);
            [i,j] = ind2sub(dim,idx); %#ok
            I = unique(i);
            n_row = numel(I);
            newh = sum(h_row(I)) + (n_row-1)*m_row;
            change = newh - sinfo.h_ctrls(n);
            sinfo.h_ctrls(n) = newh;
            sinfo.CLoffset(n) = sinfo.CLoffset(n) + change;
            sinfo.CUoffset(n) = sinfo.CUoffset(n) + change;
         end
      else % no auto-extension in heights, adjust row margin
         for n = 1:num
            idx = find(sinfo.map==n);
            [i,j] = ind2sub(dim,idx); %#ok
            I = unique(i);
            n_row = numel(I);
            if (n_row == 1)
               height(idx) = h(n);
            end
         end
         [temp, height] = distribute_spanned_controls(sinfo.map, [], height, [], h, [], Options.Sep); %#ok
         h_row = max(height,[],2);
         if (dim(1) == 1)
            m_row = 0;  % No margins for a single row
         else
            m_row = (ctrlarea(4)-sum(h_row))/(dim(1)-1);
         end
      end
      
      % set control positions
      for m = 1:num
         [i,j] = ind2sub(dim,find(sinfo.map==m));
         x0 = sum(w_col(1:j(1)-1)) + m_col*(j(1)-1) + ctrlarea(1) + workarea(1);
         y0 = sum(h_row(i(1):end)) - sinfo.h_ctrls(m) + m_row*(dim(1)-i(1)) + ctrlarea(2) + workarea(2);
         
         posL = [x0,y0+sinfo.CLoffset(m)];
         posC = [x0+sinfo.w_labels(m),y0,sinfo.w_ctrls(m),sinfo.h_ctrls(m)];
         posU = [x0+sinfo.w_labels(m)+sinfo.w_ctrls(m)+Options.UnitsMargin,y0+sinfo.CUoffset(m)];
         
         if handles.labels(m)~=0, set(handles.labels(m),'Position',posL); end
         if handles.ctrl(m)~=0, set(handles.ctrl(m),'Position',posC); end
         if handles.units(m)~=0, set(handles.units(m),'Position',posU); end
      end
      
      % set positions of buttons
      nbtns = numel(handles.btns);
      w_allbtns = Options.Sep*(nbtns-1) + nbtns*sinfo.w_btns;
      pos = [workarea(1) + btnarea(3) - w_allbtns, workarea(2), sinfo.w_btns, sinfo.h_btns];  % Right-align buttons
      for n = 1:nbtns
         set(handles.btns(n),'Position',pos);
         pos(1) = pos(1) + sinfo.w_btns + Options.Sep;
      end
   end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% BUILDGUI :: Builds the dialog box and returns handles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [handles,Formats,sinfo] = buildgui(Prompt,Unit,Title,Formats,Options)

DefaultSize.text = [0 0]; % auto size (max width: 250)
DefaultSize.edit = [165 0]; % auto size height (base:20)
DefaultSize.popupmenu = [0 20]; % auto size width
DefaultSize.listbox = [0 0];   % auto size
DefaultSize.togglebutton = [0 0]; % auto size
DefaultSize.radiobutton = [0 0]; % auto size
DefaultSize.checkbox = [0 18]; % auto size width
DefaultSize.slider = [75 15];
DefaultSize.pushbutton = [69 22];

% determine how to utilize 'none' space
% Place all the elements at (0,0)
free = reshape(strcmp('none',{Formats.type}),size(Formats)); % location of empty block to be occupied by neighbor entry
num = sum(~free(:)); % number of controls
dim = size(Formats); % display grid dimension
map = zeros(dim); % determine which control occupies which block(s)
order = zeros(1,num); % uicontrol placement order
n = 1;
for f = 1:prod(dim)
   % traverse row-first
   [j,i] = ind2sub(dim([2 1]),f);
   m = sub2ind(dim,i,j);
   
   if free(m)
      mode = diff(Formats(m).limits);
      [i,j] = ind2sub(dim,m);
      if mode>0 && j>1, map(m) = map(sub2ind(dim,i,j-1)); % left
      elseif mode<0 && i>1, map(m) = map(sub2ind(dim,i-1,j)); % above
      end % other wise, 0 (nothing occupying)
   else
      map(m) = n;
      order(n) = m;
      n = n + 1;
   end
end

% remove none's from Formats and order the rest in Prompt order
Formats = Formats(order);

% assign default size if Formats.size is non-positive
autosize = false(num,2);
autoextend = false(num,2);
for m = 1:num
   autoextend(m,:) = Formats(m).size<0;
   
   % get default size if size not specified
   if Formats(m).size(1) <=0
      Formats(m).size(1) = DefaultSize.(Formats(m).style)(1);
   end
   if Formats(m).size(2) <=0
      Formats(m).size(2) = DefaultSize.(Formats(m).style)(2);
   end
   
   % if fixed size, turn autosize off
   autosize(m,:) = Formats(m).size<=0;
end


FigColor=get(0,'DefaultUicontrolBackgroundcolor');

fig = dialog(           ...
   'Visible'     ,'off'   , ...
   'Name'       ,Title   , ...
   'Pointer'     ,'arrow'  , ...
   'Units'      ,'pixels'  , ...
   'UserData'     ,'Cancel'  , ...
   'Tag'       ,'Figure'   , ...
   'HandleVisibility' ,'on' , ...
   'Color'      ,FigColor  , ...
   'NextPlot'     ,'add'   , ...
   'WindowStyle'   ,Options.WindowStyle, ...
   'DoubleBuffer'   ,'on'    , ...
   'Resize'      ,Options.Resize    ...
   );

figSize = get(fig,'Position');

%%%%%%%%%%%%%%%%%%%%%
%%% Set Positions %%%
%%%%%%%%%%%%%%%%%%%%%
CommonInfo = {'Units'  'pixels';
   'FontSize'      get(0,'FactoryUIControlFontSize');
   'HandleVisibility'  'callback'}';

props.edit = [CommonInfo {...
   'FontWeight'   get(fig,'DefaultUicontrolFontWeight');
   'Style'      'edit';
   'HorizontalAlignment' 'left';
   'BackgroundColor' 'white'}'];

props.checkbox = [CommonInfo {...
   'Style'      'checkbox';
   'FontWeight'   get(fig,'DefaultUicontrolFontWeight');
   'HorizontalAlignment' 'left';
   'BackgroundColor' FigColor}'];

props.popupmenu = [CommonInfo {...
   'FontWeight'   get(fig,'DefaultUicontrolFontWeight');
   'Style'      'popupmenu';
   'HorizontalAlignment' 'left';
   'BackgroundColor' 'white'}'];

props.listbox = [CommonInfo {...
   'FontWeight'   get(fig,'DefaultUicontrolFontWeight');
   'Style'      'listbox';
   'HorizontalAlignment' 'left';
   'BackgroundColor' 'white'}'];

props.slider = [CommonInfo {...
   'Style'      'slider';
   }'];

props.uibuttongroup = [CommonInfo {...
   'FontWeight'   get(fig,'DefaultUicontrolFontWeight');
   'BackgroundColor' FigColor;
   }'];

props.radiobutton = props.checkbox;
props.radiobutton{2,4} = 'radiobutton';

props.pushbutton = [CommonInfo {...
   'Style'        'pushbutton';
   'FontWeight'     get(fig,'DefaultUicontrolFontWeight');
   'HorizontalAlignment' 'center'}'];

props.togglebutton = props.pushbutton;
props.togglebutton{2,4} = 'togglebutton';

% Add VerticalAlignment here as it is not applicable to the above.
TextInfo = [CommonInfo {...
   'BackgroundColor'   FigColor;
   'HorizontalAlignment' 'left';
   'VerticalAlignment'  'bottom';
   'Color'        get(0,'FactoryUIControlForegroundColor');
   'Interpreter'     Options.Interpreter}'];

% Place the container (UIPANEL & AXES) for the elements (for the ease of
% resizing)
ax = axes('Parent',fig,'Units','pixels','Visible','off',...
   'Position',[0 0 figSize(3:4)],'XLim',[0 figSize(3)],'YLim',[0 figSize(4)]);

hPrompt = zeros(num,1);
hEdit = zeros(num,1);
hUnit = zeros(num,1);
Cwidth = zeros(num,1);
Cheight = zeros(num,1);
Lwidth = zeros(num,1);
Lheight = zeros(num,1);
Uwidth = zeros(num,1);
Uheight = zeros(num,1);
CLoffset = zeros(num,1);
CUoffset = zeros(num,1);
for m = 1:num
   Formats(m).size(autosize(m,:)) = 1; % temporary width
   
   idx = strcmp(Formats(m).style,{'radiobutton','togglebutton'});
   if any(idx)
      % create the UI Button Group object
      hEdit(m) = uibuttongroup('Parent',fig,props.uibuttongroup{:},...
         'Position',[0 0 Formats(m).size],'Title',Prompt{m});
      
      if idx(1),margin = [15 0]; % radiobutton
      else margin = [10 2]; end % togglebutton
      
      num_btns = numel(Formats(m).items);
      dim_btns = size(Formats(m).items);
      hButtons = zeros(dim_btns);
      btn_w = zeros(dim_btns);
      btn_h = zeros(dim_btns);
      for k = 1:num_btns
         [j,i] = ind2sub(dim_btns([2 1]),k);
         if isempty(Formats(m).items{i,j}), continue; end % if empty string, no button at this position
         hButtons(i,j) = uicontrol('Parent',hEdit(m),'Style',Formats(m).style,props.(Formats(m).style){:},...
            'String',Formats(m).items{i,j},'Min',0,'Max',1,'UserData',k);
         pos = get(hButtons(i,j),'Extent');
         btn_w(i,j) = pos(3);
         btn_h(i,j) = pos(4);
      end
      
      set(hEdit(m),'UserData',hButtons);
      
      btn_w = btn_w + margin(1);
      btn_h = btn_h + margin(2);
      
      col_w = max(btn_w,[],1);
      row_h = max(btn_h,[],2);
      
      % set positions of buttons
      kvalid = find(hButtons~=0);
      for k = reshape(kvalid,1,numel(kvalid))
         [i,j] = ind2sub(dim_btns,k); % i-col, j-row
         pos = [sum(col_w(1:j-1))+Options.Sep*j sum(row_h(i+1:end)) + Options.Sep*(dim_btns(1)-i+0.5) btn_w(k) btn_h(k)];
         set(hButtons(i,j),'Position',pos);
      end
      
      Cwidth(m) = sum(col_w)+Options.Sep*(dim_btns(2)+1);
      Cheight(m) = sum(row_h)+Options.Sep*(dim_btns(1)+1);
      
      % no auto-extension
      autoextend(m,:) = false;
   elseif strcmp(Formats(m).type,'text') % static text (only a label)
      % create label
      if autosize(m,1) % if not autosize, wrap as needed
         str = Prompt{m};
      else
         h = uicontrol('Parent',fig,'Style','text','Position',[0 0 Formats(m).size]);
         msg = textwrap(h,Prompt(m));
         delete(h);
         str = msg{1};
         for n = 2:length(msg)
            str = sprintf('%s\n%s',str,msg{n});
         end
      end
      
      hPrompt(m) = text('Parent',ax,TextInfo{:},'Position',[0,0],'String',str);
      pos = get(hPrompt(m),'Extent');
      Lwidth(m) = pos(3);
      Lheight(m) = pos(4);
      Cheight(m) = pos(4);
      CLoffset(m) = 1;
   else
      hEdit(m) = uicontrol('Parent',fig,'Style',Formats(m).style,props.(Formats(m).style){:},...
         'Position',[0 0 Formats(m).size]);
      
      Cwidth(m) = Formats(m).size(1);
      Cheight(m) = Formats(m).size(2);
      
      % set min and max if not a numeric edit box
      if ~strcmp(Formats(m).style,'edit') || ~any(strcmp(Formats(m).format,{'float','integer','date'}))
         set(hEdit(m),'Min',Formats(m).limits(1),'Max',Formats(m).limits(2));
      end
      
      switch lower(Formats(m).style)
         case 'edit'
            textmode = any(strcmp(Formats(m).format,{'text','file'}));
            if autosize(m,2) % auto-height
               if textmode
                  dlim = diff(Formats(m).limits);
                  if (strcmp(Formats(m).format,'file') && dlim<1), dlim = 1; end
                  Cheight(m) = 15*dlim + 5;
               else % numeric -> force single-line
                  Cheight(m) = 20;
               end
               set(hEdit(m),'Position',[0 0 Formats(m).size]);
            end
            
            % If format is not text, reset Min & Max to single-line mode
            if ~textmode, set(hEdit(m),'Min',0,'Max',1); end
            
            % create label
            hPrompt(m) = text('Parent',ax,TextInfo{:},'Position',[0,0],'String',Prompt{m});
            pos = get(hPrompt(m),'Extent');
            Lwidth(m) = pos(3); % label element width
            Lheight(m) = pos(4); % label element height
            
            if ~isempty(Unit{m})
               hUnit(m) = text('Parent',ax,TextInfo{:},'Position',[0,0],'String',Unit{m});
               pos = get(hUnit(m),'Extent');
               Uwidth(m) = pos(3)+Options.UnitsMargin; % label element width
               Uheight(m) = pos(4); % label element height
            end
            
            % Align label with the editbox text location
            % editbox first-line text location varies depending on single- or multi-line mode
            if strcmp(Formats(m).format, 'date')
               multline = 0;
            else
               multline = textmode && diff(Formats(m).limits)>1;
            end
            if multline
               CLoffset(m) = 3 + Cheight(m) - Lheight(m);
               CUoffset(m) = 3 + Cheight(m) - Uheight(m);
            else
               CLoffset(m) = 3 + (Cheight(m) - Lheight(m))/2;
               CUoffset(m) = 3 + (Cheight(m) - Uheight(m))/2;
            end
            
            % height auto-extension posible only if multiline
            autoextend(m,2) = autoextend(m,2) && multline;
            if autoextend(m,1)
               Cwidth(m) = Formats(m).size(1);  % Reasonable minimum width for a resizable edit control (TODO?: Use a smaller value)
            end
            
            if strcmp(Formats(m).format,'file') && diff(Formats(m).limits)>1  % Multi-file uigetfile()
               set(hEdit(m),'UserData',{'' ''});  % UserData stores {path|DefaultName, filenames}
            elseif strcmp(Formats(m).format,'file')  % Single-file uigetfile() or uiputfile()
               set(hEdit(m),'UserData',{''});  % UserData stores {DefaultName} parameter
            end
         case 'checkbox' % no labels
            if autosize(m,1) % auto-width
               set(hEdit(m),'String',Prompt{m});
               pos = get(hEdit(m),'Extent');
               pos(3) = pos(3) + 15;
               Cwidth(m) = pos(3);%Formats(m).size(1) = pos(3);
               set(hEdit(m),'Position',pos);
            end
            
            % width auto-extension possible only if width too short
            autoextend(m,2) = false; % no height auto-extend
         case 'popupmenu'
            % force the height
            Cheight(m) = DefaultSize.popupmenu(2);
            
            % get the width of the widest entry
            if autosize(m,1) % auto-width
               for itm = 1:numel(Formats(m).items)
                  set(hEdit(m),'String',Formats(m).items{itm},'Value',1);
                  p = get(hEdit(m),'Extent');
                  if p(3)>Cwidth(m), Cwidth(m) = p(3); end
               end
               Cwidth(m) = Cwidth(m) + 19;
            end
            
            % re-set position
            set(hEdit(m),'Position',[0 0 Cwidth(m) Cheight(m)]);
            
            % set menu & choose the first entry
            set(hEdit(m),'String',Formats(m).items','Value',1);
            
            % create label
            hPrompt(m) = text('Parent',ax,TextInfo{:},'Position',[0,0],'String',Prompt{m});
            pos = get(hPrompt(m),'Extent');
            Lwidth(m) = pos(3); % label element width
            Lheight(m) = pos(4); % label element height
            
            if ~isempty(Unit{m})
               hUnit(m) = text('Parent',ax,TextInfo{:},'Position',[0,0],'String',Unit{m});
               pos = get(hUnit(m),'Extent');
               Uwidth(m) = pos(3)+Options.UnitsMargin; % label element width
               Uheight(m) = pos(4); % label element height
            end
            
            % Align label with the editbox text location
            % editbox first-line text location varies depending on single- or multi-line mode
            CLoffset(m) = 1 + Cheight(m) - Lheight(m);
            CUoffset(m) = 1 + Cheight(m) - Uheight(m);
            
            autoextend(m,:) = false;  % The width is already sized to the contents and the height can't change
         case 'listbox'
            % get the max extent
            pos = [0 0 0 0];
            for itm = 1:numel(Formats(m).items)
               set(hEdit(m),'String',Formats(m).items{itm},'Value',1);
               p = get(hEdit(m),'Extent');
               if p(3)>pos(3), pos(3) = p(3); end
            end
            pos(3) = pos(3) + 19;
            pos(4) = 13*numel(Formats(m).items)+2;
            
            % Restrict the height if a maximum number of lines was specified
            if (Formats(m).limits(1) > 0)
               pos(4) = min(pos(4), 13*Formats(m).limits(1)+2);
            end
            
            % auto-size & set autoextend
            if autosize(m,1), Cwidth(m) = pos(3); end
            if autosize(m,2), Cheight(m) = pos(4); end
            if any(autosize(m,:)), set(hEdit(m),'Position',pos); end
            
            % set table & leave it unselected
            if diff(Formats(m).limits)>1, val = [];
            else val = 1; end
            set(hEdit(m),'String',Formats(m).items','Value',val);
            
            % create label
            hPrompt(m) = text('Parent',ax,TextInfo{:},'Position',[0,0],'String',Prompt{m});
            pos = get(hPrompt(m),'Extent');
            Lwidth(m) = pos(3); % label element width
            Lheight(m) = pos(4); % label element height
            
            if ~isempty(Unit{m})
               hUnit(m) = text('Parent',ax,TextInfo{:},'Position',[0,0],'String',Unit{m});
               pos = get(hUnit(m),'Extent');
               Uwidth(m) = pos(3)+Options.UnitsMargin; % label element width
               Uheight(m) = pos(4); % label element height
            end
            
            % Align label with the editbox text location
            % editbox first-line text location varies depending on single- or multi-line mode
            CLoffset(m) = Cheight(m)-12;
            CUoffset(m) = Cheight(m)-12;
            
            autoextend(m,1) = false;  % The width is already sized to the contents
         case 'slider'
            % set slider initial value
            val = mean(Formats(m).limits);
            set(hEdit(m),'Value',val,'TooltipString',num2str(val),'Callback',@(hObj,evt)set(hObj,'TooltipString',num2str(get(hObj,'Value'))));
            
            % create label
            hPrompt(m) = text('Parent',ax,TextInfo{:},'Position',[0,0],'String',Prompt{m});
            pos = get(hPrompt(m),'Extent');
            Lwidth(m) = pos(3); % label element width
            Lheight(m) = pos(4); % label element height
            
            if ~isempty(Unit{m})
               hUnit(m) = text('Parent',ax,TextInfo{:},'Position',[0,0],'String',Unit{m});
               pos = get(hUnit(m),'Extent');
               Uwidth(m) = pos(3)+Options.UnitsMargin; % label element width
               Uheight(m) = pos(4); % label element height
            end
            
            if all(autoextend(m,:))
               % only resizable in the direction of slider
               if (diff(Formats(m).size) >= 0)  % Vertically extending slider
                  autoextend(m,1) = false;
               else  % Horizontally extending slider
                  autoextend(m,2) = false;
               end
            end
            
            if autoextend(m,1)  % Horizontally extending slider
               Cwidth(m) = Formats(m).size(1);  % Reasonable minimum length for a resizable slider control (TODO?: Use a smaller value)
            end
            if autoextend(m,2)  % Vertically extending slider
               Cheight(m) = Formats(m).size(1);  % Reasonable minimum length for a resizable slider control (TODO?: Use a smaller value)
               if (Cwidth(m) == Formats(m).size(1))  % The user probably asked to auto-size (TODO?: Save and use actual autosize value)
                  Cwidth(m) = Formats(m).size(2);  % Reasonable minimum breadth for a resizable slider control
               end
            end
            
            % Align the label and unit text with the control
            CLoffset(m) = Cheight(m) - Lheight(m) + 4;
            CUoffset(m) = Cheight(m) - Uheight(m) + 4;
      end
   end
end

hBtn(1) = uicontrol(fig,props.pushbutton{:}, 'String', Options.ButtonNames{1}, ...
                    'Position', [0 0 DefaultSize.pushbutton], 'UserData', 'OK');
if strcmpi(Options.CancelButton,'on')
   hBtn(end+1) = uicontrol(fig,props.pushbutton{:}, 'String', Options.ButtonNames{2}, ...
                           'Position', [0 0 DefaultSize.pushbutton], 'UserData', 'Cancel');
end
if strcmpi(Options.ApplyButton,'on')
   hBtn(end+1) = uicontrol(fig,props.pushbutton{:}, 'String', Options.ButtonNames{3}, ...
                           'Position', [0 0 DefaultSize.pushbutton], 'UserData', 'Apply');
end

% output handle struct
handles.fig = fig;
handles.labels = hPrompt';
handles.ctrl = hEdit';
handles.units = hUnit';
handles.btns = hBtn;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Optionally align adjacent controls in each column
if strcmpi(Options.AlignControls, 'on')
   for n = 1 : size(map, 2)
      current_map_column = map(:,n);
      num_controls = length(current_map_column);
      alignable = false(num_controls, 1);  % Controls in this column that can be aligned
      
      for m = 1 : num_controls
         control_index = current_map_column(m);
         if (control_index > 0) && ~any(strcmp(Formats(control_index).type, {'text', 'check', 'none'})) ...  % Not static text, a checkbox, or a placeholder
               && ~(strcmp(Formats(control_index).type, 'list') && any(strcmp(Formats(control_index).style, {'radiobutton', 'togglebutton'})))  % Not a radiobutton or togglebutton
            alignable(m) = true;  % Only controls with a label on the left are alignable
         end
      end
      
      if (n > 1)
         [temp, already_handled] = intersect(current_map_column, map(:,n-1)); %#ok
         alignable(already_handled) = false;  % Controls spanned from a previous column have already been handled
      end
      
      % Align controls in groups consisting of all adjacent alignable controls
      m = 1;
      while (m <= num_controls)
         while (m <= num_controls) && ~alignable(m)  % Skip until the first alignable control of the next group
            m = m + 1;
         end
         group_start = m;
         
         while (m <= num_controls) && alignable(m)  % Skip until the last alignable control of the group
            m = m + 1;
         end
         group_end = m - 1;
         
         alignment_group = current_map_column(group_start:group_end);
         Lwidth(alignment_group) = max(Lwidth(alignment_group));  % Align controls by giving them the same label width
      end
   end
end

% determine the minimum figure size
w = Cwidth+Lwidth+Uwidth;
h = max([Cheight,Lheight,Uheight],[],2);

% distribute width & height according to map
width = zeros(size(map));
height = zeros(size(map));
for n = 1:num
   idx = find(map==n);
   [i,j] = ind2sub(dim,idx);
   I = unique(i);
   J = unique(j);
   n_row = numel(I);
   n_col = numel(J);
   
   if (n_col == 1)
      width(idx) = w(n);
   end
   if (n_row == 1)
      height(idx) = h(n);
   end
end
[width, height] = distribute_spanned_controls(map, width, height, w, h, [], Options.Sep);
col_w = max(width,[],1);
row_h = max(height,[],2);

wmin_ctrls = sum(col_w) + Options.Sep*(dim(2)-1);
hmin_ctrls = sum(row_h) + Options.Sep*(dim(1)-1);
nbtns = numel(handles.btns);
btns_w = nbtns*DefaultSize.pushbutton(1) + (nbtns-1)*Options.Sep;
btns_h = DefaultSize.pushbutton(2);

figSize(3:4) = [max(wmin_ctrls,btns_w)+2*Options.Sep hmin_ctrls+btns_h+2*Options.Sep];

set(fig,'Position',figSize);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sinfo.minfigsize = figSize(3:4);  % minimum figure size
sinfo.map = map;        % uicontrol map
sinfo.autoextend = autoextend; % auto-extend when resize (to use the full span of figure window)
sinfo.w_labels = Lwidth;    % width of labels
sinfo.w_ctrls = Cwidth;    % width of controls
sinfo.w_units = Uwidth;
sinfo.h_labels = Lheight;   % height of labels
sinfo.h_ctrls = Cheight;    % height of controls
sinfo.h_units = Uheight;
sinfo.CLoffset = CLoffset;   % label y offset w.r.t. control
sinfo.CUoffset = CUoffset;
sinfo.w_btns = DefaultSize.pushbutton(1);
sinfo.h_btns = DefaultSize.pushbutton(2);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CHECKPROMPT :: Check Prompt input is valid & fill default values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Prompt,FieldNames,Units,err] = checkprompt(Prompt)

% default configuration
FieldNames = {}; % answer in a cell
Units = {}; % no units

% standard error
err = {'inputsdlg:InvalidInput','Prompt must be a cell string with up to three columns.'};

if isempty(Prompt), Prompt = {'Input:'};
elseif ~iscell(Prompt), Prompt = cellstr(Prompt);
end

[nrow,ncol] = size(Prompt);

% prompt given in a row -> transpose
if ncol>3
   if nrow<3, Prompt = Prompt'; [nrow,ncol] = size(Prompt);
   else return; end
end

% struct fields defined
if ncol>1 && ~all(cellfun('isempty',Prompt(:,2))), FieldNames = Prompt(:,2); end

% unit labels defined
if ncol>2, Units = Prompt(:,3);
else Units = repmat({''},nrow,1); end

% return only the labels
Prompt = Prompt(:,1);

err = {}; % all cleared

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CHECKFORMATS :: Check Formats input is valid & fill default values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Formats,err] = checkformats(Formats,NumQuest)

fields  = [{'type' 'style' 'items' 'format' 'limits'  'size' 'enable'};...
   {'edit' 'edit'  {''}  'text'  [0 1]   [0 0] 'on'}]; % defaults
err = {};

if isempty(Formats)
   Formats = repmat(struct(fields{:}),NumQuest,1);
   return
end

% backward compatibility (NumLines)
if isnumeric(Formats)
   [rw,cl]=size(Formats);
   ok = rw==1;
   if ok
      OneVect = ones(NumQuest,1);
      if cl == 2, NumLines=Formats(OneVect,:);
      elseif cl == 1, NumLines=Formats(OneVect);
      elseif cl == NumQuest, NumLines = Formats';
      else ok = false;
      end
   end
   if rw == NumQuest && any(cl == [1 2]), NumLines = Formats;
   elseif ~ok
      err = {'MATLAB:inputdlg:IncorrectSize', 'NumLines size is incorrect.'};
      return;
   end
   
   % set to default edit control (column stacked)
   Formats = repmat(struct(fields{:}),NumQuest,1);
   
   % set limits according to NumLines(:,1)
   numlines = mat2cell([zeros(NumQuest,1) NumLines(:,1)],ones(NumQuest,1),2);
   [Formats.limits] = deal(numlines{:});
   
   % sets the width to be 10*NumLines(:,2)
   if (size(NumLines,2) == 2)
      sizes = mat2cell([zeros(NumQuest,1) NumLines(:,2)],ones(NumQuest,1),2);
      [Formats.size] = deal(sizes{:});
   end
   
   return;
elseif ischar(Formats) || iscellstr(Formats) % given type
   if ischar(Formats), Formats = cellstr(Formats); end
   Formats = cell2struct(Formats,'type',3);
elseif ~isstruct(Formats)
   err = {'inputsdlg:InvalidInput','FORMATS must be an array of structure.'};
   return
end

% check fields
% for n = 1:size(fields,2)
%    if ~isfield(Formats,fields{1,n})
%       Formats.(fields{1,n}) = [];
%    end
% end
idx = find(~isfield(Formats,fields(1,:)));
for n = idx % if does not exist, use default
%    [Formats.(fields{1,n})] = deal([]);
   [Formats.(fields{1,n})] = deal(fields{2,n});
end

% set string fields to lower case
c = lower(cellfun(@char,{Formats.type},'UniformOutput',false));
[Formats.type] = deal(c{:});
c = lower(cellfun(@char,{Formats.style},'UniformOutput',false));
[Formats.style] = deal(c{:});
c = lower(cellfun(@char,{Formats.format},'UniformOutput',false));
[Formats.format] = deal(c{:});

% check number of entries matching NumQuest (number of PROMPT elements)
if sum(~strcmp('none',{Formats.type})&~strcmp('',{Formats.type}))~=NumQuest
   err = {'inputsdlg:InvalidInput','FORMATS must have matching number of elements to PROMPT (exluding ''none'' type).'};
   return
end

% check type field contents
if ~isempty(setdiff({Formats.type},{'check','edit','list','range','text','none',''}))
   err = {'inputsdlg:InvalidInput','FORMATS.type must be one of {''check'',''edit'',''list'',''range'',''none''}.'};
   return
end

% check format
if ~isempty(setdiff({Formats.format},{'text','date','float','integer','file','dir',''}))
   err = {'inputsdlg:InvalidInput','FORMATS.format must be one of {''text'', ''float'', or ''integer''}.'};
   return
end

num = numel(Formats);
for n = 1:num
   if isempty(Formats(n).type), Formats(n).type = 'none'; end
   
   switch Formats(n).type
      case 'none'
         if isempty(Formats(n).limits), Formats(n).limits = [0 0]; end
      case 'text'
         if isempty(Formats(n).style)
            Formats(n).style = 'text';
         elseif ~strcmp(Formats(n).style,'text');
            err = {'inputsdlg:InvalidInput','FORMATS.style for ''text'' type must be ''text''.'};
            return
         end
      case 'check'
         % check style
         if isempty(Formats(n).style)
            Formats(n).style = 'checkbox';
         elseif ~strcmp(Formats(n).style,'checkbox')
            err = {'inputsdlg:InvalidInput','FORMATS.style for ''check'' type must be ''checkbox''.'};
            return
         end
         
         % check format
         if isempty(Formats(n).format)
            Formats(n).format = 'integer';
         elseif any(strcmp(Formats(n).format,{'text','float'}))
            err = {'inputsdlg:InvalidInput','FORMATS.format for ''check'' type must be ''integer''.'};
            return
         end
      case 'edit'
         % check style
         if isempty(Formats(n).style)
            Formats(n).style = 'edit';
         elseif ~strcmp(Formats(n).style,'edit')
            err = {'inputsdlg:InvalidInput','FORMATS.style for ''edit'' type must be ''edit''.'};
            return
         end
         
         % check format
         if isempty(Formats(n).format)
            Formats(n).format = 'text';
         elseif strcmp(Formats(n).format,'file') && isempty(Formats(n).items)
            Formats(n).items = {'*.*' 'All Files'};
         end
      case 'list'
         % check style
         if isempty(Formats(n).style)
            Formats(n).style = 'popupmenu';
         elseif ~any(strcmp(Formats(n).style,{'listbox','popupmenu','radiobutton','togglebutton'}))
            err = {'inputsdlg:InvalidInput','FORMATS.style for ''list'' type must be either ''listbox'', ''popupmenu'', ''radiobutton'', or ''togglebutton''.'};
            return
         end
         
         % check items
         if isempty(Formats(n).items)
            err = {'inputsdlg:InvalidInput','FORMATS.items must contain strings for the ''list'' type.'};
            return
         end
         if ~iscell(Formats(n).items)
            if ischar(Formats(n).items)
               Formats(n).items = cellstr(Formats(n).items);
            elseif isnumeric(Formats(n).items)
               Formats(n).items = cellfun(@num2str,num2cell(Formats(n).items),'UniformOutput',false);
            else
               err = {'inputsdlg:InvalidInput','FORMATS.items must be either a cell of strings or of numbers.'};
               return
            end
         end
         
         % check format
         if isempty(Formats(n).format)
            Formats(n).format = 'integer';
         elseif any(strcmp(Formats(n).format,{'text','float'}))
            err = {'inputsdlg:InvalidInput','FORMATS.format must be ''integer'' for the ''list'' type.'};
            return
         end
      case 'range'
         % check style
         if isempty(Formats(n).style)
            Formats(n).style = 'slider';
         elseif ~strcmp(Formats(n).style,'slider')
            err = {'inputsdlg:InvalidInput','FORMATS.style for ''range'' type must be ''slider''.'};
            return
         end
         
         if isempty(Formats(n).format)
            Formats(n).format = 'float';
         elseif ~strcmp(Formats(n).format,'float')
            err = {'inputsdlg:InvalidInput','FORMATS.format for ''range'' type must be ''float''.'};
            return
         end
   end
   
   % check limits
   if isempty(Formats(n).limits)
      if strcmp(Formats(n).style,'edit') && any(strcmp(Formats(n).format,{'integer','float'}))
         Formats(n).limits = [-inf inf]; % default for numeric edit box
      elseif strcmp(Formats(n).style,'edit') && any(strcmp(Formats(n).format,{'date'}))
         Formats(n).limits = 0; % default to 'dd-mmm-yyyy HH:MM:SS'
      else
         Formats(n).limits = [0 1]; % default for all other controls
      end
   else
      if strcmp(Formats(n).type,'edit') && any(strcmp(Formats(n).format,{'date'}))
         if ischar(Formats(n).limits) && ~isempty(Formats(n).limits) && (size(Formats(n).limits, 1) == 1)
            try
               datestr(1, Formats(n).limits);  % Try forming a string with the given free-form format string
            catch  %#ok
               err = {'inputsdlg:InvalidInput', 'Invalid free-form format string in FORMATS.limits for ''date'' control.'};
               return;
            end
         elseif ~isnumeric(Formats(n).limits) || numel(Formats(n).limits)~=1 || isnan(Formats(n).limits)...
               || ~any(Formats(n).limits==[0 1 2 6 13 14 15 16 23])
            err = {'inputsdlg:InvalidInput','FORMATS.limits for ''date'' format must be one of 0,1,2,6,13,14,15,16,23.'};
            return;
         end
      else
         if strcmp(Formats(n).type, 'edit') && strcmp(Formats(n).format, 'integer')
            Formats(n).limits(1) = ceil(Formats(n).limits(1));   % Round any floating point limits
            Formats(n).limits(2) = floor(Formats(n).limits(2));  % to the nearest acceptable integers
         end
         if ~isnumeric(Formats(n).limits) || ~any(numel(Formats(n).limits)==[1 2]) || any(isnan(Formats(n).limits)) ... % 2-element numeric vector and cannot be NaN
               || (~(strcmp(Formats(n).type,'check')||(strcmp(Formats(n).type,'edit')&&any(strcmp(Formats(n).format,{'file','integer','float'})))||strcmp(Formats(n).type,'none')) && Formats(n).limits(1)>=Formats(n).limits(2)) ...
               ... % if not check, edit::file/integer/float, or none, has to be increasing
               || (strcmp(Formats(n).type, 'edit') && any(strcmp(Formats(n).format, {'integer', 'float'})) && (Formats(n).limits(1) > Formats(n).limits(2))) ...
               ... % if edit::integer/float, has to be equal or increasing
               || (~(strcmp(Formats(n).type,'edit') && any(strcmp(Formats(n).format,{'float','integer'}))) && any(isinf(Formats(n).limits))) % if not edit::float/integer, has to be finite
            
            err = {'inputsdlg:InvalidInput','FORMATS.limits must be increasing and non-NaN.'};
            return
         end
         if numel(Formats(n).limits)==1, Formats(n).limits(2) = 0; end
      end
   end
   
   % check size
   if isempty(Formats(n).size)
      Formats(n).size = [0 0]; % default to auto-size
   else
      if ~isnumeric(Formats(n).size) || ~any(numel(Formats(n).size)==[1 2]) || any(isnan(Formats(n).size))
         err = {'inputsdlg:InvalidInput','FORMATS.size must be non-NaN.'};
         return
      end
      if numel(Formats(n).size)==1
         Formats(n).size(2) = 0;
      end
   end
   
   % check enable
   if isempty(Formats(n).enable)
      Formats(n).enable = fields{2,7};
   elseif ~any(strcmpi(Formats(n).enable,{'on','inactive','off'}))
         err = {'inputsdlg:InvalidInput','FORMATS.enable must be one of {''on'',''inactive'',''off''}.'};
         return;
   end
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% CHECKDEFAULTS :: Check the specified default values are compatible
%%% with Formats and if one not given fill in an initial value
function [DefAns,DefStr,err] = checkdefaults(DefAns,Formats,FieldNames)

DefStr = struct([]); % struct not used

% trim Formats to only include relevant entries (non-'none' types)
Formats = Formats'; % go through row first
Formats = Formats(~strcmp('none',{Formats.type}));
len = numel(Formats);

if isempty(DefAns) % if DefAns not given
   DefAns = cell(len,1); % will set DefAns to default values
elseif isstruct(DefAns)
   if isempty(FieldNames) % struct return
      err = {'inputsdlg:InvalidInput','Default answer given in a structure but the prompts do not have associated answer field names in the second column.'};
      return;
   end
   if ~all(isfield(DefAns,FieldNames)|cellfun('isempty',FieldNames))
      err = {'inputsdlg:InvalidInput','Default answer structure is missing at least one answer field.'};
      return;
   end
   DefStr = DefAns;
   DefAns = cell(len,1);
   for k = 1:len
      if ~isempty(FieldNames{k}), DefAns{k} = DefStr.(FieldNames{k}); end
   end
elseif ~iscell(DefAns)
   err = {'inputsdlg:InvalidInput','Default answer must be given in a cell array or a structure.'};
   return;
elseif length(DefAns)~=len
   err = {'inputsdlg:InvalidINput','Default answer cell dimension disagrees with the number of prompt'};
   return;
end

err = {'inputsdlg:InvalidInput','Default value is not consistent with Formats.'};

% go through each default values
for k = 1:len
   if isempty(DefAns{k}) % set non-empty default values
      switch Formats(k).type
         case 'check' % off
            DefAns{k} = Formats(k).limits(1);
         case 'edit'
            switch Formats(k).format
               case {'text','file','dir','date'}
                  DefAns{k} = ''; % change to empty string
               case {'float','integer'}
                  liminf = isinf(Formats(k).limits);
                  if all(liminf) % both limits inf
                     DefAns{k} = 0;
                  elseif any(liminf) % 1 limit inf
                     DefAns{k} = Formats(k).limits(~liminf);
                  else
                     DefAns{k} = round(mean(Formats(k).limits));
                  end
            end
         case 'list' % first item
            DefAns{k} = 1;
         case 'range' % middle value
            DefAns{k} = mean(Formats(k).limits);
      end
   else % check given values
      msel = strcmp(Formats(k).style,'listbox') && diff(Formats(k).limits)>1;
      switch Formats(k).format
         case 'text'
            if ~(isempty(DefAns{k}) || ischar(DefAns{k})), return; end
         case 'date'
            try
               num = datenum(DefAns{k});
            catch %#ok
               err{2} = 'Invalid default date.';
               return;
            end
            DefAns{k} = datestr(num, Formats(k).limits);
         case 'float'
            if ~isfloat(DefAns{k}) || numel(DefAns{k})~=1, return; end
         case 'integer' % can be multi-select if type=list
            if ~islogical(DefAns{k}) ...
                  && (~isnumeric(DefAns{k}) || any(DefAns{k}~=floor(DefAns{k})) || (~msel && numel(DefAns{k})~=1))
               return;
            end
         case 'file'
            dlim = diff(Formats(k).limits);
            if ~isempty(DefAns{k}) && dlim>=0 % for uigetfile
               if dlim<=1 % single-file
                  if ~ischar(DefAns{k})
                     err{2} = 'Default file parameter must be stored in a character string.';
                     return;
                  end
                  files = DefAns(k);
               else %dlim>1 % multiple-files
                  if ischar(DefAns{k}) && (size(DefAns{k}, 1) == 1)
                     files = DefAns(k);
                  elseif iscellstr(DefAns{k})
                     files = DefAns{k};
                  else
                     err{2} = 'Default file parameter(s) must be stored in a character string or cellstring.';
                     return;
                  end
               end
               if (length(files) > 1)  % More than one file argument
                  file_path = fileparts(files{1});
                  if isempty(file_path)
                     err{2} = 'Default file names must include the complete path.';
                     return;
                  end
                  for n = 1:length(files)
                     if ~isequal(file_path, fileparts(files{n}))
                        err{2} = 'Default files must be in the same directory.';
                        return;
                     end
                     d = dir(files{n});
                     if ~isempty(files{n}) && length(d)~=1
                        err{2} = 'Default file name does not resolve to a unique file.';
                        return;
                     end
                  end
               end
               % A single file argument will later be treated as a DefaultName if it doesn't resolve to a unique file
            end
         case 'dir'
            if isempty(DefAns{k}) || ~isdir(DefAns{k})
               err{2} = 'Default directory does not exist.';
               return;
            end
      end
      
      switch Formats(k).type
         case 'check' % must be one of the values in limits
            if all(DefAns{k} ~= Formats(k).limits), return; end
         case 'edit' % if numeric, must be within the limits
            if any(strcmp(Formats(k).format,{'float','integer'})) ...
                  && (DefAns{k}<Formats(k).limits(1) || DefAns{k}>Formats(k).limits(2))
               return;
            end
            
         case 'list' % has to be valid index to the list
            if any(DefAns{k}<1) || any(DefAns{k}>numel(Formats(k).items)), return; end
            
         case 'range' % has to be within the limits
            if DefAns{k}<Formats(k).limits(1) || DefAns{k}>Formats(k).limits(2)
               return;
            end
      end
   end
end

% also initialize DefStr if FieldNames given
if isempty(DefStr) && ~isempty(FieldNames)
   idx = ~cellfun('isempty',FieldNames);
   StructArgs = [FieldNames(idx) DefAns(idx)]';
   DefStr = struct(StructArgs{:});
end

err = {}; % all good
end

function [Options,err] = checkoptions(UserOptions)

err = {'inputsdlg:InvalidInput',''};

Fields = {'Resize',        'off'
          'WindowStyle',   'normal'
          'Interpreter',   'tex'
          'CancelButton',  'on'
          'ApplyButton',   'off'
          'ButtonNames',   {{'OK','Cancel','Apply'}}
          'Sep',           10
          'AlignControls', 'off'
          'UnitsMargin',    5}.';

Options = struct(Fields{:});

if isempty(UserOptions) % no option specified, use default
   err = {};
   return;
elseif numel(UserOptions)~=1
   err{2} = 'Options struct must be a scalar.';
   return;
end

% check if User Resize Option is given as on/off string
if ischar(UserOptions) && strcmpi(UserOptions,{'on','off'})
   UserOptions.Resize = UserOptions;
elseif ~isstruct(UserOptions)
   err{2} = 'Options must be ''on'', ''off'', or a struct.';
   return;
end

% check UserOptions struct & update Options fields
for fname_cstr = fieldnames(UserOptions)' % for each user option field
   
   fname = char(fname_cstr); % use plain char string (not cellstr)
   if ischar(UserOptions.(fname)), UserOptions.(fname)=cellstr(UserOptions.(fname)); end
   
   % if field not filled, use default value
   if isempty(UserOptions.(fname)), continue; end
   
   switch lower(fname)
      case 'resize'
         if numel(UserOptions.(fname))~=1 || ~any(strcmpi(UserOptions.(fname),{'on','off'}))
            err{2} = 'Resize option must be ''on'' or ''off''.';
            return;
         end
         Options.Resize = char(UserOptions.(fname));
      case 'windowstyle'
         if numel(UserOptions.(fname))~=1 || ~any(strcmpi(UserOptions.(fname),{'normal','modal','docked'}))
            err{2} = 'WindowStyle option must be ''normal'' or ''modal''.';
            return;
         end
         Options.WindowStyle = char(UserOptions.(fname));
      case 'interpreter'
         if numel(UserOptions.(fname))~=1 || ~any(strcmpi(UserOptions.(fname),{'latex','tex','none'}))
            err{2} = 'Interpreter option must be ''latex'', ''tex'', or ''none''.';
            return;
         end
         Options.Interpreter = char(UserOptions.(fname));
      case 'cancelbutton'
         if numel(UserOptions.(fname))~=1 || ~any(strcmpi(UserOptions.(fname),{'on','off'}))
            err{2} = 'CancelButton option must be ''on'' or ''off''.';
            return;
         end
         Options.CancelButton = char(UserOptions.(fname));
      case 'applybutton'
         if numel(UserOptions.(fname))~=1 || ~any(strcmpi(UserOptions.(fname),{'on','off'}))
            err{2} = 'ApplyButton option must be ''on'' or ''off''.';
            return;
         end
         Options.ApplyButton = char(UserOptions.(fname));
      case 'buttonnames'
         if ~iscellstr(UserOptions.(fname))
            err{2} = 'ButtonNames option must be of cellstr or char type.';
            return;
         end
         
         % if not all 3 button names are given, use default for unspecified
         N = numel(UserOptions.(fname));
         if (N>3)
            err{2} = 'ButtonNames option takes up to 3 button names.';
            return;
         end
         Options.ButtonNames(1:N) = UserOptions.(fname);
      case 'sep'
         if numel(UserOptions.(fname))~=1 || ~isnumeric(UserOptions.(fname)) || UserOptions.(fname)<0
            err{2} = 'Sep option must be non-negative scalar value.';
            return;
         end
         Options.Sep = UserOptions.(fname);
      case 'aligncontrols'
         if numel(UserOptions.(fname))~=1 || ~any(strcmpi(UserOptions.(fname),{'on','off'}))
            err{2} = 'AlignControls option must be ''on'' or ''off''.';
            return;
         end
         Options.AlignControls = char(UserOptions.(fname));
      case 'unitsmargin'
         if numel(UserOptions.(fname))~=1 || ~isnumeric(UserOptions.(fname)) || UserOptions.(fname)<0
            err{2} = 'UnitsMargin option must be non-negative scalar value.';
            return;
         end
         Options.UnitsMargin = UserOptions.(fname);
      otherwise
         warning('inputsdlg:InvalidOption','%s is not a valid option name.',fname);
   end
end

err = {}; % all cleared
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DISTRIBUTE_SPANNED_CONTROLS :: Distribute the width/height of controls that
% span multiple columns/rows in a manner that minimizes the creation of
% excess blank space and distributes it evenly among columns/rows.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [map_widths, map_heights] = distribute_spanned_controls(map, map_widths, map_heights, control_widths, control_heights, autoextend, margin)

num_controls = max(map(:));

if ~exist('map_widths', 'var') || isempty(map_widths) || ~exist('control_widths', 'var') || isempty(control_widths)
   map_widths = zeros(size(map));
   control_widths = zeros(num_controls, 1);
end
if ~exist('map_heights', 'var') || isempty(map_heights) || ~exist('control_heights', 'var') || isempty(control_heights)
   map_heights = zeros(size(map));
   control_heights = zeros(num_controls, 1);
end
if ~exist('autoextend', 'var') || isempty(autoextend)
   autoextend = false(num_controls, 2);
end
if ~exist('margin', 'var') || isempty(margin)
   margin = 10;
end

for k = 1 : num_controls
   min_column_widths = max(map_widths, [], 1);
   min_row_heights = max(map_heights, [], 2);
   
   logical_control_indexes = (map == k);
   linear_control_indexes = find(logical_control_indexes);
   [i, j] = ind2sub(size(map), linear_control_indexes);
   control_rows = unique(i);
   control_columns = unique(j);
   num_control_rows = numel(control_rows);
   num_control_columns = numel(control_columns);
   
   if (num_control_rows > 1) && ~autoextend(k,2)  % The control spans multiple rows and is not auto-extendable
      % Distribute as much of the control's height as possible in the existing row heights
      remaining_height = max(control_heights(k) - margin*(num_control_rows-1), 0);
      for m = 1 : num_control_rows
         row_index = control_rows(m);
         row_mask = false(size(map));
         row_mask(row_index,:) = true;
         used_height = min(remaining_height, min_row_heights(row_index));
         map_heights(logical_control_indexes & row_mask) = used_height;
         remaining_height = remaining_height - used_height;
      end
      
      % Add any remaining necessary height evenly to the control's rows
      map_heights(logical_control_indexes) = map_heights(logical_control_indexes) + remaining_height/num_control_rows;
   end
   
   if (num_control_columns > 1) && ~autoextend(k,1)  % The control spans multiple columns and is not auto-extendable
      % Distribute as much of the control's width as possible in the existing column widths
      remaining_width = max(control_widths(k) - margin*(num_control_columns-1), 0);
      for m = 1 : num_control_columns
         column_index = control_columns(m);
         column_mask = false(size(map));
         column_mask(:,column_index) = true;
         used_width = min(remaining_width, min_column_widths(column_index));
         map_widths(logical_control_indexes & column_mask) = used_width;
         remaining_width = remaining_width - used_width;
      end
      
      % Add any remaining necessary width evenly to the control's columns
      map_widths(logical_control_indexes) = map_widths(logical_control_indexes) + remaining_width/num_control_columns;
   end
end

end

% Copyright (c) 2009-2010, Takeshi Ikuma
% Copyright (c) 2010, Luke Reisner
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
%   * Redistributions of source code must retain the above copyright
%     notice, this list of conditions and the following disclaimer.
%   * Redistributions in binary form must reproduce the above copyright
%     notice, this list of conditions and the following disclaimer in the
%     documentation and/or other materials provided with the distribution.
%   * Neither the names of its contributors may be used to endorse or
%     promote products derived from this software without specific prior
%     written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
