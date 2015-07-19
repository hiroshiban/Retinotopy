function [imgs,imgsize,IFD,MPE,header]=imreadmpo(mpofile,save_jpg_flg)

% Reads an MPO (multiple picture object) file.
% function [imgs,imgsize,IFD,MPE,header]=imreadmpo(mpofile,:save_flg)
% (: is optional)
%
% This function reads an input MPO file and stores the image data as a MATLAB matrix.
% It is especially focusing on loading two (left/right-eyes) images extracted from
% one MPO photo file taken with FujiFilm Real W3 stereo camera and storing them
% separately into a MATLAB matrix. Any MPO file can be processed but have not fully
% tested yet.
%
% [input]
% mpofile      : input MPO-file name, a RELATIVE path format as the location
%                where this function is called is the origin
%                e.g. mpofile='../DSCF0008.mpo';
% save_jpg_flg : whether saving the separated jpeg file. [0|1]. 0 by defaut.
%
% [output]
% imgs         : image object, a cell strucuture
% imgsize      : image size, [height, width]
% IFD          : MP index IDF information
% MPE          : MP entry information
% header       : header information of the input MPO file
%
% [note]
% The MPO header structure is as below
% FF E2 00 9E 4D 50 46 00 | 4D 4D 00 2A | 00 00 00 08 | 00 03 B0 00 00 07 ...
%      (APP2 marker)      |  (endian)      (offset)   |  (MP index IFD, 12 byte x N blocks)   ... (image data)
%                         |                           |
%                         | <-- offset_start          | <-- mp_idx
%
%
% Created    : "2015-06-30 09:21:28 ban"
% Last Update: "2015-07-02 10:24:12 ban"

% check the input variable
mpofile=fullfile(pwd,mpofile);
if ~exist(mpofile,'file'), error('can not find mpofile. check the input variable.'); end

if nargin<2 || isempty(save_jpg_flg), save_jpg_flg=0; end

% load the input mpo file and store the content
finput=fopen(mpofile,'rb');
if finput==-1, error('can not read mpofile. check the inpur variable.'); end
data=fread(finput,Inf,'uint8')';
fclose(finput);

% find JPEG APP2 header positions
% APP2 marker is as below
% address  : +00  +01  +02  +03      +04      +05      +06       +07
% code(hex):  FF   E2   --   --  4D('M')  50('P')  46('F')  00(NULL)
% therefore, the elements in the first tmp_idx should be less than numel(data)-8

% get the first "FF E2" marker
tmp_idx1=find(data==hex2dec('FF'));
tmp_idx1(tmp_idx1>=numel(data)-8)=[];

tmp_idx2=logical(data(tmp_idx1+1)==hex2dec('E2'));
app2_start=tmp_idx1(tmp_idx2);
clear tmp_idx1 tmp_idx2;

% then, search the "4D 50 46 00" marker
offset_counter=0;
offset_start=[];
for ii=1:1:numel(app2_start)
  if sum(strcmp(dec2hex(data(app2_start(ii)+4:app2_start(ii)+7)),{'4D','50','46','00'}))==4
    offset_counter=offset_counter+1;
    offset_start(offset_counter)=app2_start(ii)+8; %#ok % start position of the byte order mark
  end
end

% get endian
% note: the next 4 bytes are endian (4D 3D 00 2A = big endian, 49 49 2A 00 = little endian)
if sum(strcmp(dec2hex(data(offset_start(1):offset_start(1)+3)),{'49','49','2A','00'}))==4
  endian='LE';
elseif sum(strcmp(dec2hex(data(offset_start(1):offset_start(1)+3)),{'4D','4D','00','2A'}))==4
  endian='BE';
else
  error('unexpected endian: can not identify the byte order of the input file. check the input file format.');
end

% get MP index IFD
mp_idx=zeros(numel(offset_start),1);
for ii=1:1:numel(offset_start)
  mp_offset=bytereader(data(offset_start(ii)+4:offset_start(ii)+7),endian);
  mp_idx(ii)=offset_start(ii)+mp_offset; % start position of the MP index IFD
end

% interpret MP index IFD, IFD consists of 12 byte blocks
for ii=1:1:1%numel(mp_idx) % the first IFD information is enough to separate jpeg files from the input MPO.
  IFD(ii).Count = bytereader(data(mp_idx(ii)+0:mp_idx(ii)+1),endian);              %#ok

  IFD(ii).version.tag      = bytereader(data(mp_idx(ii)+2:mp_idx(ii)+3),endian);   %#ok
  IFD(ii).version.type     = bytereader(data(mp_idx(ii)+4:mp_idx(ii)+5),endian);   %#ok
  IFD(ii).version.count    = bytereader(data(mp_idx(ii)+6:mp_idx(ii)+9),endian);   %#ok
  IFD(ii).version.offset   = bytereader(data(mp_idx(ii)+10:mp_idx(ii)+13),endian); %#ok

  IFD(ii).number.tag       = bytereader(data(mp_idx(ii)+14:mp_idx(ii)+15),endian); %#ok
  IFD(ii).number.type      = bytereader(data(mp_idx(ii)+16:mp_idx(ii)+17),endian); %#ok
  IFD(ii).number.count     = bytereader(data(mp_idx(ii)+18:mp_idx(ii)+21),endian); %#ok
  IFD(ii).number.offset    = bytereader(data(mp_idx(ii)+22:mp_idx(ii)+25),endian); %#ok

  IFD(ii).entryIdx.tag     = bytereader(data(mp_idx(ii)+26:mp_idx(ii)+27),endian); %#ok
  IFD(ii).entryIdx.type    = bytereader(data(mp_idx(ii)+28:mp_idx(ii)+29),endian); %#ok
  IFD(ii).entryIdx.count   = bytereader(data(mp_idx(ii)+30:mp_idx(ii)+33),endian); %#ok
  IFD(ii).entryIdx.offset  = bytereader(data(mp_idx(ii)+34:mp_idx(ii)+37),endian); %#ok
end

% get each image offset and byte length, interpreting MP entry
for ii=1:1:IFD(1).number.offset % IFD.number.offset = the number of images contained in the target MPO file
  current_offset=offset_start(1)+IFD(1).entryIdx.offset+16*(ii-1); % since MP entry consists of 16 byte blocks

  MPE(ii).ImageAttr       = bytereader(data(current_offset+0:current_offset+3),endian);   %#ok
  MPE(ii).ImageSize       = bytereader(data(current_offset+4:current_offset+7),endian);   %#ok
  MPE(ii).ImageDataOffset = bytereader(data(current_offset+8:current_offset+11),endian);  %#ok
  MPE(ii).DependentImage1 = bytereader(data(current_offset+12:current_offset+13),endian); %#ok
  MPE(ii).DependentImage2 = bytereader(data(current_offset+14:current_offset+15),endian); %#ok
end

% get the image size information
tmp_idx1=find(data==hex2dec('FF'));
tmp_idx1(tmp_idx1>=numel(data)-2)=[];

tmp_idx2=logical(data(tmp_idx1+1)==hex2dec('C0')); % using FFC0 tag to extract image size information
sof_start=tmp_idx1(tmp_idx2);

tmp_idx3=logical(data(tmp_idx1+1)==hex2dec('C4')); % using FFC4 tag (DHT = Haffman table) as the border
sof_edge=tmp_idx1(tmp_idx3);

sof_start=max(sof_start(sof_start<sof_edge(end))); % this is not good in interpreting the header, but required to speeding up the process.
clear tmp_idx1 tmp_idx2 tmp_idx3;

imgsize=[256*data(sof_start+5)+data(sof_start+6),256*data(sof_start+7)+data(sof_start+8)];

% extract and store the image data object
imgs=cell(IFD(1).number.offset,1);
for ii=1:1:IFD(1).number.offset
  if ii==1
    current_offset=0;
  else
    current_offset=offset_start(1)+MPE(ii).ImageDataOffset-1; % here, -1 is to adjust the start point.
  end

  imgdata=data(current_offset+1:current_offset+MPE(ii).ImageSize);

  [dummy,mpofname]=fileparts(mpofile); %#ok
  outfname=sprintf('%s_%02d.jpg',mpofname,ii);
  fout=fopen(fullfile(pwd,outfname),'w');
  c=onCleanup(@() fclose(fout));
  fwrite(fout,imgdata,'uint8');
  clear c;

  imgs{ii}=imread(fullfile(pwd,outfname));
  if ~save_jpg_flg, delete(fullfile(pwd,outfname)); end
end

if nargout>4, header=imfinfo(mpofile); end

return


%% subfunction

function output=bytereader(data,endian)

% Converts the input decimal byte data with the specified byte-order format
% function output=bytereader(data,endian)
%
% [input]
% data   : byte array, e.g. data=[8 0 0 0];
% endian : byte order, 'LE' or 'BE'
%
% [output]
% output : decimal data formatted by the given endian

if strcmp(endian,'LE')
  tmpdata=dec2hex(fliplr(data));
  data=[];
  for ii=1:1:size(tmpdata,1), data=strcat(data,tmpdata(ii,:)); end
  output=hex2dec(data);
else % if strcmp(endian,'BE')
  tmpdata=dec2hex(data);
  data=[];
  for ii=1:1:size(tmpdata,1), data=strcat(data,tmpdata(ii,:)); end
  output=hex2dec(data);
end

return
