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
% Last Update: "2021-06-25 13:46:20 ban"

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
% [EyeLink data *.asc file is organized something as below]
% (some header lines are coming first...)
% ** CONVERTED FROM SINWAVE.EDF using edfapi 3.1 Win32 Jul  4 2014 on Tue Jun 22 22:14:41 2021
% ** DATE: Tue Jun 22 04:00:53 2021
% ** TYPE: EDF_FILE BINARY EVENT SAMPLE TAGGED
% ** VERSION: EYELINK II 1
% ** SOURCE: EYELINK CL
% ** EYELINK II CL v5.15 Jan 24 2018
% ** CAMERA: Eyelink GL Version 1.2 Sensor=AH7
% ** SERIAL NUMBER: CLG-BGA46
% ** CAMERA_CONFIG: BGA46200.SCD
% ** RECORDED BY TRACK 2.0
% **
% (some other header lines are coming first...)
% EVENTS	HREF	LEFT	RIGHT	RATE	2000.00	TRACKING	CR	FILTER	2
% SAMPLES	GAZE	LEFT	RIGHT	RATE	2000.00	TRACKING	CR	FILTER	2 <-- I am using this line as a header end marker
% (then...,)
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

% get header lines
headerline=fgetl(fid);
data.header=headerline;
while ~strcmpi(headerline,'**')
  headerline=fgetl(fid);
  data.header=[data.header,newline(),headerline];
end
data.header=data.header(1:end-3); % 3 = '**' + newline()

% skip addtional pieces of header information (in the near future, these sections should be somehow stored)
headerline=fgetl(fid);
while isempty(headerline), headerline=fgetl(fid); end

cur_data=textscan(headerline,'%s','delimiter','\t');
while ~strcmpi(cur_data{1}{1},'START')
  headerline=fgetl(fid);
  if ~isempty(headerline)
    cur_data=textscan(headerline,'%s','delimiter','\t');
  end
end
start_time=str2double(cur_data{1}{2});
for ii=1:1:5, headerline=fgetl(fid); end %#ok % omit the additional header lines
clear headerline;

% NOTE:
% After this line, just for accelerating the processing speed, I will skip to classify
% the contents into data and tags based on the preserved markers. If you are going to
% cut data at your own time stamp (trigger/flags/mesasges), plesse rewrite the codes below.

% read the first reliable data after skipping line with some preserved markers
dataline=fgetl(fid);
cur_data=textscan(dataline,'%s',1,'delimiter','\t');
while strcmpi(cur_data{1}{1},'MSG') || strcmpi(cur_data{1}{1},'INPUT') || ...
      strcmpi(cur_data{1}{1},'EVENTS') || strcmpi(cur_data{1}{1},'SAMPLES') || ...
      contains(cur_data{1}{1},'SBLINK') || contains(cur_data{1}{1},'EBLINK') || ...
      contains(cur_data{1}{1},'SFIX') || contains(cur_data{1}{1},'SSACC') || ...
      contains(dataline,'.C.') || contains(dataline,'.R.') || contains(dataline,'.L.')
  dataline=fgetl(fid);
  cur_data=textscan(dataline,'%s',1,'delimiter','\t');
end

if contains(dataline,'.....')
  record_mode='bino';
else % contains(dataline,'...')
  record_mode='mono';
end
clear dataline;

[dummy,ascfname,ascext]=fileparts(ascfile); %#ok
fprintf('processing: %s%s (mode: %s)...',ascfname,ascext,record_mode);

% processing
while 1
  cur_line=fgetl(fid);
  linecounter=linecounter+1;
  if cur_line==-1  % EOF
    break;
  elseif strcmp(record_mode,'mono') && strcmp(cur_line(end-2:end),'...') % data obtained correctly
    cur_data=textscan(cur_line,'%d%f%f%f%s','delimiter','\t');
    data.eyedata(linecounter,1)=double(cur_data{1})-start_time; % time
    for ii=2:1:4 % X1, X2, X3
      if ~isempty(cur_data{ii})
        data.eyedata(linecounter,ii)=double(cur_data{ii});
      else
        data.eyedata(linecounter,ii)=fill_val;
      end
    end
  elseif strcmp(record_mode,'bino') && strcmp(cur_line(end-4:end),'.....') % data obtained correctly
    cur_data=textscan(cur_line,'%d%f%f%f%f%f%f%s','delimiter','\t');
    data.eyedata(linecounter,1)=double(cur_data{1}-start_time); % time
    for ii=2:1:7 % X1, X2, X3, Y1, Y2, Y3
      if ~isempty(cur_data{ii})
        data.eyedata(linecounter,ii)=double(cur_data{ii});
      else
        data.eyedata(linecounter,ii)=fill_val;
      end
    end
  else % error. e.g. the final 3 characters are ".C.", "RC." etc.
    data.eyedata(linecounter,1)=str2double(cur_line(1:7))-start_time; % time
  end
end
data.eyedata(data.eyedata==0)=NaN;
disp('done.');

fclose(fid);

return
