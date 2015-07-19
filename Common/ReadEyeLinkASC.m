function data=ReadEyeLinkASC(ascfile,fill_val)

% Reads an EyeLink log (*.asc) file and retuns data array as a matrix.
% function data=ReadEyeLinkASC(ascfile,:fill_val)
% (: is optional)
%
% [input]
% ascfile  : a file name specified with a relative path format.
%            the origin of the path should be the directory where
%            this function is called.
% fill_val : (optional) a value to fill the missing data points due to blinks, saccades etc.
%            NaN by default.
%
% [output]
% data     : a matrix (sampling_points x 4(mono-eye) or 7(bino-eye) positions) of the eye movement records.
%            here, 4 = time, X1, X2, X3
%                  7 = time, X1, X2, X3, Y1, Y2, Y3
%
%
% Created    : "2014-10-08 11:25:17 ban"
% Last Update: "2014-10-08 20:02:26 ban"

% check input varialbes
if nargin<1, help(mfilename()); if nargout, data=[]; end; return; end
if nargin<2 || isempty(fill_val), fill_val=NaN; end

% check the target file
ascfile=fullfile(pwd,ascfile);
if ~exist(ascfile,'file'), error('can not find ascfile: %s. check input variable.',ascfile); end

% open the asc file
fid=fopen(ascfile,'r');
if fid==-1, error('can not open ascfile: %s. close it first.',acsfile); end

% determine whether the target asc is a record of mono-eye or both-eyes.
% NOTE 1: the file content will be as below. so we can discriminate both records
%         by reading the first line temporally, getting the the *end-3* character,
%         and checking whether it is "." or "\t".
%
% for mono-eye  : time1 val1_1 val1_2 val1_3 ... (here the final "..." is a kind of flag)
%                 time2 val2_1 val2_2 val2_3 ...
%                 time3 val3_1 val3_2 val3_3 ...
%                 (continued)
%
% for both-eyes : time1 val1_1 val1_2 val1_3 val1_4 val1_5 val1_6 ..... (here the final "....." is a kind of flag)
%                 time2 val2_1 val2_2 val2_3 val2_4 val2_5 val2_6 .....
%                 time3 val3_1 val3_2 val3_3 val3_4 val3_5 val3_6 .....
%                 (continued)
%
% NOTE 2: if data is not obtained at some specific point due to blinks etc,
%         the final "..." or "....." will be like ".C.", ".R.", ".C..R".
%         we can validate the data by checkinig these characters.

firstline=fgetl(fid);
start_time=str2double(firstline(1:7));
tgt_char=firstline(end-3);
if strcmp(tgt_char,'.')
  record_mode='bino';
else % if strcmp(tgt_char,'\t')
  record_mode='mono';
end
clear firstline tgt_char;

[dummy,ascfname,ascext]=fileparts(ascfile); %#ok
fprintf('processing: %s%s (mode: %s)...',ascfname,ascext,record_mode);

% get the numbe of lines and initialize the output data matrix
linecounter=1; % as already the first line is read
while 1
  tmp=fgetl(fid);
  if tmp==-1, break; end
  linecounter=linecounter+1;
end
if strcmp(record_mode,'mono')
  data=fill_val.*ones(linecounter,4);
else % if strcmp(record_mode,'bino')
  data=fill_val.*ones(linecounter,7);
end

% rewind the file identifier
frewind(fid);

% processing
if strcmp(record_mode,'mono')
  linecounter=0;
  while 1
    cur_line=fgetl(fid);
    linecounter=linecounter+1;
    if cur_line==-1  % EOF
      break;
    elseif strcmp(cur_line(end-2:end),'...') % data obtained correctly
      cur_data=textscan(cur_line,'%d%f%f%f%s','delimiter','\t');
      data(linecounter,1)=cur_data{1}-start_time; % time
      for ii=2:1:4 % X1, X2, X3
        data(linecounter,ii)=cur_data{ii};
      end
    else % error. e.g. the final 3 characters are ".C.", "RC." etc.
      data(linecounter,1)=str2double(cur_line(1:7))-start_time; % time
    end
  end
else % if strcmp(record_mode,'bino')
  linecounter=0;
  while 1
    cur_line=fgetl(fid);
    linecounter=linecounter+1;
    if cur_line==-1  % EOF
      break;
    elseif strcmp(cur_line(end-4:end),'.....') % data obtained correctly
      cur_data=textscan(cur_line,'%d%f%f%f%f%f%f%s','delimiter','\t');
      data(linecounter,1)=cur_data{1}-start_time; % time
      for ii=2:1:7 % X1, X2, X3, Y1, Y2, Y3
        data(linecounter,ii)=cur_data{ii};
      end
    else % error. e.g. the final 5 characters are ".C.C.", ".R.C." etc.
      data(linecounter,1)=str2double(cur_line(1:7))-start_time; % time
    end
  end
end
disp('done.');

fclose(fid);

return
