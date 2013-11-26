function ms=mseq(baseVal,powerVal,shift,whichSeq,balance_flag,user_taps)

% Generates maximum-length sequence(s).
% function ms=mseq(baseVal,powerVal,shift,whichSeq,balance_flag,user_taps)
%
% Maximum length sequence assuming 2,3,4,5,7,8,9,11,13 distinct values
%
%   ms=mseq(baseVal,powerVal,:shift,:whichSeq,:balance_flag,:user_taps)
%   (: is optional)
%
% [input]
% baseVal  : base, number of sequence levels, one of 2,3,4,5,7,8,9,11,13
% powerVal : power so that sequence m-sequence length is
%            length=baseVal^powerVal-1
% shift    : cyclical shift of the sequence
% whichSeq : sequence instantiation to use
%            (number of sequence varies with powerval.
%             For details, please check the code)
% balance_flag : if 1, the sequence will be balanced [0/1]
%                e.g. 0,2,1,1,0,2,1 -> 0,1,-1,-1,0,1,-1
% user_taps: use user-defined tap
%
% [output]
% ms = generated maximum length sequence, of length basisVal^powerVal-1
%
% [history]
%
% * Original script is written by Giedrius T. Buracas, SNL-B, Salk Institute
%   Register values are taken from: WDT Davies, System Identification
%   for self-adaptive control. Wiley-Interscience, 1970
%  
% * Modifications are by Thomas Liu, UCSD Center for fMRI to extend the Mods
%   020915 TTL added basevals =  4, 7, 8, 9, 11, 13
%              tap combos are from K. Godfrey, Perturbation Signals for
%              System Identification, Prentice Hall 1993
%   020929 TTL adding optional taps option to try out different taps
%   020930 TTL - expanding the number of tap options for baseval =11, power
%                 =2; these tap options were found by brute-force simulation
%              - got rid of the conversion from positive integers to
%                signed ints.. 
%   send comments and questions to ttliu@ucsd.edu
%
% * Modifications are made by Hiroshi Ban
%   100302 balance_flag, used for calculating auto-correlation etc.
%   100302 check input variables, adding default value
%   100302 refining the source code
%   100302 bug fix for polynominal at baseVal=2, powerVal=8, & whichSeq=14
%   100303 add polynominals (powerVal={11-32} for baseVal=2)
%
%   reference 1: http://www-mobile.ecs.soton.ac.uk/bjc97r/pnseq.old/doc.html
%   reference 2: W.W.Peterson, "Error Correctiong Codes," MIT Press,
%                Wiley, New York.
%   reference 3: W.P.Horton, "Shift Counters," Computer Control Corporation.
%   reference 4: R.C.White,Jr., "Experiments with Digital Computer Simulation
%                of Pseudo-Random Noise Gerenatiors, " IEEE Trans. Elect.
%                Comp., June 1967.
%
% Created    : "2010-03-02 15:15:01 Hiroshi Ban"
% Last Update: "2013-11-22 23:35:44 ban (ban.hiroshi@gmail.com)"


%% check input variables
if nargin < 2
  help mseq; return;
end

base=[2,3,4,5,7,8,9,11,13];
if isempty(intersect(baseVal,base))
  error('baseVal should be one of 2,3,4,5,7,8,9,11,13.');
end
  
if nargin < 3 || isempty(shift), shift=1; end
if nargin < 4 || isempty(whichSeq), whichSeq=[]; end
if nargin < 5 || isempty(balance_flag), balance_flag=0; end
if nargin < 6 || isempty(user_taps), user_taps=[]; end


%% set the initial tap & register
bitNum=baseVal^powerVal-1;
register=ones(powerVal,1);

%foo=bitNum;
%for i=1:powerVal
%   register(i)=rem(foo,baseVal); 
%   foo=(foo-register(i))/baseVal;
%end

%ind=find(register==0); register(ind)=-1*ones(length(ind),1); %values 

if baseVal==2
  
  switch powerVal
    case 2
      tap(1).No=[1,2];
    case 3
      tap(1).No=[1,3];
      tap(2).No=[2,3];
    case 4
      tap(1).No=[1,4];
      tap(2).No=[3,4];
    case 5
      tap(1).No=[2,5];
      tap(2).No=[3,5];
      tap(3).No=[1,2,3,5];
      tap(4).No=[2,3,4,5];
      tap(5).No=[1,2,4,5];
      tap(6).No=[1,3,4,5];
    case 6
      tap(1).No=[1,6];
      tap(2).No=[5,6];
      tap(3).No=[1,2,5,6];
      tap(4).No=[1,4,5,6];
      tap(5).No=[1,3,4,6];
      tap(6).No=[2,3,5,6];
    case 7
      tap(1).No=[1,7];
      tap(2).No=[6,7];
      tap(3).No=[3,7];
      tap(4).No=[4,7];
      tap(5).No=[1,2,3,7];
      tap(6).No=[4,5,6,7];
      tap(7).No=[1,2,5,7];
      tap(8).No=[2,5,6,7];
      tap(9).No=[2,3,4,7];
      tap(10).No=[3,4,5,7];
      tap(11).No=[1,3,5,7];
      tap(12).No=[2,4,6,7];
      tap(13).No=[1,3,6,7];
      tap(14).No=[1,4,6,7];
      tap(15).No=[2,3,4,5,6,7];
      tap(16).No=[1,2,3,4,5,7];
      tap(17).No=[1,2,4,5,6,7];
      tap(18).No=[1,2,3,5,6,7];
    case 8
      tap(1).No=[1,2,7,8];
      tap(2).No=[1,6,7,8];
      tap(3).No=[1,3,5,8];
      tap(4).No=[3,5,7,8];
      tap(5).No=[2,3,4,8];
      tap(6).No=[4,5,6,8];
      tap(7).No=[2,3,5,8];
      tap(8).No=[3,5,6,8];
      tap(9).No=[2,3,6,8];
      tap(10).No=[2,5,6,8];
      tap(11).No=[2,3,7,8];
      tap(12).No=[1,5,6,8];
      tap(13).No=[1,2,3,4,6,8];
      %tap(14).No=[2,4,5,7,8]; !BUG! This polynominal can not construct m-sequence
      tap(14).No=[1,2,3,6,7,8];
      tap(15).No=[1,2,5,6,7,8];
    case 9
      tap(1).No=[4,9];
      tap(2).No=[5,9];
      tap(3).No=[3,4,6,9];
      tap(4).No=[3,5,6,9];
      tap(5).No=[4,5,8,9];
      tap(6).No=[1,4,5,9];
      tap(7).No=[1,4,8,9];
      tap(8).No=[1,5,8,9];
      tap(9).No=[2,3,5,9];
      tap(10).No=[4,6,7,9];
      tap(11).No=[5,6,8,9];
      tap(12).No=[1,3,4,9];
      tap(13).No=[2,7,8,9];
      tap(14).No=[1,2,7,9];
      tap(15).No=[2,4,7,9];
      tap(16).No=[2,5,7,9];
      tap(17).No=[2,4,8,9];
      tap(18).No=[1,5,7,9];
      tap(19).No=[1,2,4,5,6,9];
      tap(20).No=[3,4,5,7,8,9];
      tap(21).No=[1,3,4,6,7,9];
      tap(22).No=[2,3,5,6,8,9];
      tap(23).No=[3,5,6,7,8,9];
      tap(24).No=[1,2,3,4,6,9];
      tap(25).No=[1,5,6,7,8,9];
      tap(26).No=[1,2,3,4,8,9];
      tap(27).No=[1,2,3,7,8,9];
      tap(28).No=[1,2,6,7,8,9];
      tap(29).No=[1,3,5,6,8,9];
      tap(30).No=[1,3,4,6,8,9];
      tap(31).No=[1,2,3,5,6,9];
      tap(32).No=[3,4,6,7,8,9];
      tap(33).No=[2,3,6,7,8,9];
      tap(34).No=[1,2,3,6,7,9];
      tap(35).No=[1,4,5,6,8,9];
      tap(36).No=[1,3,4,5,8,9];
      tap(37).No=[1,3,6,7,8,9];
      tap(38).No=[1,2,3,6,8,9];
      tap(39).No=[2,3,4,5,6,9];
      tap(40).No=[3,4,5,6,7,9];
      tap(41).No=[2,4,6,7,8,9];
      tap(42).No=[1,2,3,5,7,9];
      tap(43).No=[2,3,4,5,7,9];
      tap(44).No=[2,4,5,6,7,9];
      tap(45).No=[1,2,4,5,7,9];
      tap(46).No=[2,4,5,6,7,9];
      tap(47).No=[1,3,4,5,6,7,8,9];
      tap(48).No=[1,2,3,4,5,6,8,9];
    case 10
      tap(1).No=[3,10];
      tap(2).No=[7,10];
      tap(3).No=[2,3,8,10];
      tap(4).No=[2,7,8,10];
      tap(5).No=[1,3,4,10];
      tap(6).No=[6,7,9,10];
      tap(7).No=[1,5,8,10];
      tap(8).No=[2,5,9,10];
      tap(9).No=[4,5,8,10];
      tap(10).No=[2,5,6,10];
      tap(11).No=[1,4,9,10];
      tap(12).No=[1,6,9,10];
      tap(13).No=[3,4,8,10];
      tap(14).No=[2,6,7,10];
      tap(15).No=[2,3,5,10];
      tap(16).No=[5,7,8,10];
      tap(17).No=[1,2,5,10];
      tap(18).No=[5,8,9,10];
      tap(19).No=[2,4,9,10];
      tap(20).No=[1,6,8,10];
      tap(21).No=[3,7,9,10];
      tap(22).No=[1,3,7,10];
      tap(23).No=[1,2,3,5,6,10];
      tap(24).No=[4,5,7,8,9,10];
      tap(25).No=[2,3,6,8,9,10];
      tap(26).No=[1,2,4,7,8,10];
      tap(27).No=[1,5,6,8,9,10];
      tap(28).No=[1,2,4,5,9,10];
      tap(29).No=[2,5,6,7,8,10];
      tap(30).No=[2,3,4,5,8,10];
      tap(31).No=[2,4,6,8,9,10];
      tap(32).No=[1,2,4,6,8,10];
      tap(33).No=[1,2,3,7,8,10];
      tap(34).No=[2,3,7,8,9,10];
      tap(35).No=[3,4,5,8,9,10];
      tap(36).No=[1,2,5,6,7,10];
      tap(37).No=[1,4,6,7,9,10];
      tap(38).No=[1,3,4,6,9,10];
      tap(39).No=[1,2,6,8,9,10];
      tap(40).No=[1,2,4,8,9,10];
      tap(41).No=[1,4,7,8,9,10];
      tap(42).No=[1,2,3,6,9,10];
      tap(43).No=[1,2,6,7,8,10];
      tap(44).No=[2,3,4,8,9,10];
      tap(45).No=[1,2,4,6,7,10];
      tap(46).No=[3,4,6,8,9,10];
      tap(47).No=[2,4,5,7,9,10];
      tap(48).No=[1,3,5,6,8,10];
      tap(49).No=[3,4,5,6,9,10];
      tap(50).No=[1,4,5,6,7,10];
      tap(51).No=[1,3,4,5,6,7,8,10];
      tap(52).No=[2,3,4,5,6,7,9,10];
      tap(53).No=[3,4,5,6,7,8,9,10];
      tap(54).No=[1,2,3,4,5,6,7,10];
      tap(55).No=[1,2,3,4,5,6,9,10];
      tap(56).No=[1,4,5,6,7,8,9,10];
      tap(57).No=[2,3,4,5,6,8,9,10];
      tap(58).No=[1,2,4,5,6,7,8,10];
      tap(59).No=[1,2,3,4,6,7,9,10];
      tap(60).No=[1,3,4,6,7,8,9,10];
    case 11
      tap(1).No=[9,11];
      tap(2).No=[11,1];
      tap(3).No=[11,8,5,2];
      tap(4).No=[11,7,3,2];
      tap(5).No=[11,5,3,2,];
      tap(6).No=[11,10,3,2];
      tap(7).No=[11,6,5,1];
      tap(8).No=[11,5,3,1];
      tap(9).No=[11,9,4,1];
      tap(10).No=[11,8,6,2];
      tap(11).No=[11,9,8,3];
    case 12
      tap(1).No=[6,8,11,12];
      tap(2).No=[12,6,4,1]; 
      tap(3).No=[12,9,3,2]; 
      tap(4).No=[12,11,10,5,2,1]; 
      tap(5).No=[12,11,6,4,2,1]; 
      tap(6).No=[12,11,9,7,6,5]; 
      tap(7).No=[12,11,9,5,3,1]; 
      tap(8).No=[12,11,9,8,7,4]; 
      tap(9).No=[12,11,9,7,6,5]; 
      tap(10).No=[12,9,8,3,2,1]; 
      tap(11).No=[12,10,9,8,6,2]; 
    case 13
      tap(1).No=[9,10,12,13];
      tap(2).No=[13,4,3,1]; 
      tap(3).No=[13,10,9,7,5,4]; 
      tap(4).No=[13,11,8,7,4,1]; 
      tap(5).No=[13,12,8,7,6,5]; 
      tap(6).No=[13,9,8,7,5,1]; 
      tap(7).No=[13,12,6,5,4,3]; 
      tap(8).No=[13,12,11,9,5,3]; 
      tap(9).No=[13,12,11,5,2,1]; 
      tap(10).No=[13,12,9,8,4,2]; 
      tap(11).No=[13,8,7,4,3,2]; 
    case 14
      tap(1).No=[4,8,13,14];
      tap(2).No=[14,12,2,1]; 
      tap(3).No=[14,13,4,2]; 
      tap(4).No=[14,13,11,9]; 
      tap(5).No=[14,10,6,1]; 
      tap(6).No=[14,11,6,1]; 
      tap(7).No=[14,12,11,1]; 
      tap(8).No=[14,6,4,2]; 
      tap(9).No=[14,11,9,6,5,2]; 
      tap(10).No=[14,13,6,5,3,1]; 
      tap(11).No=[14,13,12,8,4,1]; 
      tap(12).No=[14,8,7,6,4,2]; 
      tap(13).No=[14,10,6,5,4,1]; 
      tap(14).No=[14,13,12,7,6,3]; 
      tap(15).No=[14,13,11,10,8,3];
    case 15
      tap(1).No=[14,15];
      tap(2).No=[15,13,10,9]; 
      tap(3).No=[15,13,10,1]; 
      tap(4).No=[15,14,9,2]; 
      tap(5).No=[15,1]; 
      tap(6).No=[15,9,4,1]; 
      tap(7).No=[15,12,3,1]; 
      tap(8).No=[15,10,5,4]; 
      tap(9).No=[15,10,5,4,3,2]; 
      tap(10).No=[15,11,7,6,2,1]; 
      tap(11).No=[15,7,6,3,2,1]; 
      tap(12).No=[15,10,9,8,5,3]; 
      tap(13).No=[15,12,5,4,3,2]; 
      tap(14).No=[15,10,9,7,5,3]; 
      tap(15).No=[15,13,12,10]; 
      tap(16).No=[15,13,10,2]; 
      tap(17).No=[15,12,9,1]; 
      tap(18).No=[15,14,12,2]; 
      tap(19).No=[15,13,7,4,1]; 
      tap(20).No=[15,13,7,4];
    case 16
      tap(1).No=[4,13,15,16];
      tap(2).No=[16,12,3,1]; 
      tap(3).No=[16,12,9,6]; 
      tap(4).No=[16,9,4,3]; 
      tap(5).No=[16,12,7,2]; 
      tap(6).No=[16,10,7,6]; 
      tap(7).No=[16,15,7,2]; 
      tap(8).No=[16,9,5,2]; 
      tap(9).No=[16,13,9,6]; 
      tap(10).No=[16,15,4,2]; 
      tap(11).No=[16,15,9,4]; 
    case 17
      tap(1).No=[14,17];
      tap(2).No=[17,3]; 
      tap(3).No=[17,3,2,1]; 
      tap(4).No=[17,7,4,3]; 
      tap(5).No=[17,16,3,1]; 
      tap(6).No=[17,12,6,3,2,1]; 
      tap(7).No=[17,8,7,6,4,3]; 
      tap(8).No=[17,11,8,6,3,2]; 
      tap(9).No=[17,9,8,6,4,1]; 
      tap(10).No=[17,16,14,10,3,2]; 
      tap(11).No=[17,12,11,8,5,2]; 
    case 18
      tap(1).No=[11,18];
      tap(2).No=[18,7]; 
      tap(3).No=[18,10,7,5]; 
      tap(4).No=[18,13,11,9,8,7,6,3]; 
      tap(5).No=[18,17,16,15,10,9,8,7]; 
      tap(6).No=[18,15,12,11,9,8,7,6]; 
    case 19
      tap(1).No=[14,17,18,19];
      tap(2).No=[19,5,2,1]; 
      tap(3).No=[19,13,8,5,4,3]; 
      tap(4).No=[19,12,10,9,7,3]; 
      tap(5).No=[19,17,15,14,13,12,6,1]; 
      tap(6).No=[19,17,15,14,13,9,8,4,2,1]; 
      tap(7).No=[19,16,13,11,10,9,4,1]; 
      tap(8).No=[19,9,8,7,6,3]; 
      tap(9).No=[19,16,15,13,12,9,5,4,2,1]; 
      tap(10).No=[19,18,15,14,11,10,8,5,3,2]; 
      tap(11).No=[19,18,17,16,12,7,6,5,3,1]; 
    case 20
      tap(1).No=[17,20];
      tap(2).No=[20,3]; 
      tap(3).No=[20,9,5,3]; 
      tap(4).No=[20,19,4,3]; 
      tap(5).No=[20,11,8,6,3,2]; 
      tap(6).No=[20,17,14,10,7,4,3,2]; 
    case 21
      tap(1).No=[19,21];
      tap(2).No=[21,2]; 
      tap(3).No=[21,14,7,2]; 
      tap(4).No=[21,13,5,2]; 
      tap(5).No=[21,14,7,6,3,2]; 
      tap(6).No=[21,8,7,4,3,2]; 
      tap(7).No=[21,10,6,4,3,2]; 
      tap(8).No=[21,15,10,9,5,4,3,2]; 
      tap(9).No=[21,14,12,7,6,4,3,2]; 
      tap(10).No=[21,2019,18,5,4,3,2]; 
    case 22
      tap(1).No=[21,22];
      tap(2).No=[22,1]; 
      tap(3).No=[22,9,5,1]; 
      tap(4).No=[22,20,18,16,6,4,2,1]; 
      tap(5).No=[22,19,16,13,10,7,4,1]; 
      tap(6).No=[22,17,9,7,2,1]; 
      tap(7).No=[22,17,13,12,8,7,2,1]; 
      tap(8).No=[22,14,13,12,7,3,2,1]; 
    case 23
      tap(1).No=[18,23];
      tap(2).No=[23,4]; 
      tap(3).No=[23,5]; 
      tap(4).No=[23,17,11,5]; 
      tap(5).No=[23,5,4,1]; 
      tap(6).No=[23,12,5,4]; 
      tap(7).No=[23,21,7,5]; 
      tap(8).No=[23,16,13,6,5,3]; 
      tap(9).No=[23,11,10,7,6,5]; 
      tap(10).No=[23,15,10,9,7,5,4,3]; 
      tap(11).No=[23,17,11,9,8,5,4,1]; 
      tap(12).No=[23,18,16,13,11,8,5,2]; 
    case 24
      tap(1).No=[17,22,23,24];
      tap(2).No=[24,7,2]; 
      tap(3).No=[24,4,3,1]; 
      tap(4).No=[24,22,20,18,16,14,11,9,8,7,5,4]; 
      tap(5).No=[24,21,19,18,17,16,15,14,13,10,9,5,4,1]; 
    case 25
      tap(1).No=[22,25];
      tap(2).No=[25,3]; 
      tap(3).No=[25,3,21]; 
      tap(4).No=[25,20,5,3]; 
      tap(5).No=[25,12,4,3]; 
      tap(6).No=[25,17,10,3,2,1]; 
      tap(7).No=[25,23,21,19,9,7,5,3]; 
      tap(8).No=[25,18,12,11,6,5,4]; 
      tap(9).No=[25,20,16,11,5,3,2,1]; 
      tap(10).No=[25,12,11,8,7,6,4,3]; 
    case 26
      tap(1).No=[20,24,25,26];
      tap(2).No=[26,6,2,1]; 
      tap(3).No=[26,22,21,16,12,11,10,8,5,4,3,1]; 
    case 27
      tap(1).No=[22,25,26,27];
      tap(2).No=[27,5,2,1]; 
      tap(3).No=[27,18,11,10,9,5,4,3]; 
    case 28
      tap(1).No=[25,28];
      tap(2).No=[28,3]; 
      tap(3).No=[28,13,11,9,5,3]; 
      tap(4).No=[28,22,11,10,4,3]; 
      tap(5).No=[28,24,20,16,12,8,4,3,2,1]; 
    case 29
      tap(1).No=[27,29];
      tap(2).No=[29,2]; 
      tap(3).No=[29,20,11,2]; 
      tap(4).No=[29,13,7,2]; 
      tap(5).No=[29,21,5,2]; 
      tap(6).No=[29,26,5,2]; 
      tap(7).No=[29,19,16,6,3,2]; 
      tap(8).No=[29,18,14,6,3,2]; 
    case 30
      tap(1).No=[7,28,29,30];
      tap(2).No=[30,23,2,1]; 
      tap(3).No=[30,6,4,1]; 
      tap(4).No=[30,24,20,16,14,13,11,7,2,1]; 
    case 31
      tap(1).No=[31,29,21,17]; 
      tap(2).No=[31,28,19,15]; 
      tap(3).No=[31,3]; 
      tap(4).No=[31,3,2,1]; 
      tap(5).No=[31,13,8,3]; 
      tap(6).No=[31,30,29,25]; 
      tap(7).No=[31,28,24,10]; 
      tap(8).No=[31,20,15,5,4,3];
      tap(9).No=[31,16,8,4,3,2];
    case 32
      tap(1).No=[32,22,2,1];
      tap(2).No=[32,7,5,3,2,1];
      tap(3).No=[32,28,19,18,16,14,11,10,9,6,5,1];
    otherwise
      error('M-sequence %.0f^%.0f is not defined',baseVal,powerVal);
  end % switch powerVal
  
elseif baseVal==3
  
  switch powerVal
    case 2
      tap(1).No=[2,1];
      tap(2).No=[1,1];
    case 3
      tap(1).No=[0,1,2];
      tap(2).No=[1,0,2];
      tap(3).No=[1,2,2];
      tap(4).No=[2,1,2];
    case 4
      tap(1).No=[0,0,2,1];
      tap(2).No=[0,0,1,1];
      tap(3).No=[2,0,0,1];
      tap(4).No=[2,2,1,1];
      tap(5).No=[2,1,1,1];
      tap(6).No=[1,0,0,1];
      tap(7).No=[1,2,2,1];
      tap(8).No=[1,1,2,1];
    case 5
      tap(1).No=[0,0,0,1,2]; 
      tap(2).No=[0,0,0,1,2];
      tap(3).No=[0,0,1,2,2];
      tap(4).No=[0,2,1,0,2];
      tap(5).No=[0,2,1,1,2];
      tap(6).No=[0,1,2,0,2];
      tap(7).No=[0,1,1,2,2];
      tap(8).No=[2,0,0,1,2];
      tap(9).No=[2,0,2,0,2];
      tap(10).No=[2,0,2,2,2];
      tap(11).No=[2,2,0,2,2];
      tap(12).No=[2,2,2,1,2];
      tap(13).No=[2,2,1,2,2];
      tap(14).No=[2,1,2,2,2];
      tap(15).No=[2,1,1,0,2];
      tap(16).No=[1,0,0,0,2];
      tap(17).No=[1,0,0,2,2];
      tap(18).No=[1,0,1,1,2];
      tap(19).No=[1,2,2,2,2];
      tap(20).No=[1,1,0,1,2];
      tap(21).No=[1,1,2,0,2];
    case 6
      tap(1).No=[0,0,0,0,2,1];
      tap(2).No=[0,0,0,0,1,1];
      tap(3).No=[0,0,2,0,2,1];
      tap(4).No=[0,0,1,0,1,1];
      tap(5).No=[0,2,0,1,2,1];
      tap(6).No=[0,2,0,1,1,1];
      tap(7).No=[0,2,2,0,1,1];
      tap(8).No=[0,2,2,2,1,1];
      tap(9).No=[2,1,1,1,0,1];
      tap(10).No=[1,0,0,0,0,1];
      tap(11).No=[1,0,2,1,0,1];
      tap(12).No=[1,0,1,0,0,1];
      tap(13).No=[1,0,1,2,1,1];
      tap(14).No=[1,0,1,1,1,1];
      tap(15).No=[1,2,0,2,2,1];
      tap(16).No=[1,2,0,1,0,1];
      tap(17).No=[1,2,2,1,2,1];
      tap(18).No=[1,2,1,0,1,1];
      tap(19).No=[1,2,1,2,1,1];
      tap(20).No=[1,2,1,1,2,1];
      tap(21).No=[1,1,2,1,0,1];
      tap(22).No=[1,1,1,0,1,1];
      tap(23).No=[1,1,1,2,0,1];
      tap(24).No=[1,1,1,1,1,1];
    case 7
      tap(1).No=[0,0,0,0,2,1,2];
      tap(2).No=[0,0,0,0,1,0,2];
      tap(3).No=[0,0,0,2,0,2,2];
      tap(4).No=[0,0,0,2,2,2,2];
      tap(5).No=[0,0,0,2,1,0,2];
      tap(6).No=[0,0,0,1,1,2,2];
      tap(7).No=[0,0,0,1,1,1,2];
      tap(8).No=[0,0,2,2,2,0,2];
      tap(9).No=[0,0,2,2,1,2,2];
      tap(10).No=[0,0,2,1,0,0,2];
      tap(11).No=[0,0,2,1,2,2,2];
      tap(12).No=[0,0,1,0,2,1,2];
      tap(13).No=[0,0,1,0,1,1,2];
      tap(14).No=[0,0,1,1,0,1,2];
      tap(15).No=[0,0,1,1,2,0,2];
      tap(16).No=[0,2,0,0,0,2,2];
      tap(17).No=[0,2,0,0,1,0,2];
      tap(18).No=[0,2,0,0,1,1,2];
      tap(19).No=[0,2,0,2,2,0,2];
      tap(20).No=[0,2,0,2,1,2,2];
      tap(21).No=[0,2,0,1,1,0,2];
      tap(22).No=[0,2,2,0,2,0,2];
      tap(23).No=[0,2,2,0,1,2,2];
      tap(24).No=[0,2,2,2,2,1,2];
      tap(25).No=[0,2,2,2,1,0,2];
      tap(26).No=[0,2,2,1,0,1,2];
      tap(27).No=[0,2,2,1,2,2,2];
    otherwise
      error('M-sequence %.0f^%.0f is not defined',baseVal,powerVal);
  end % switch powerVal
  
elseif baseVal==4
  
  switch powerVal
    case 2
      tap(1).No = [1,2];
    case 3
      tap(1).No=[1,1,2];
    case 4
      tap(1).No = [1,2,2,2];
    otherwise
      error('M-sequence %.0f^%.0f is not defined',baseVal,powerVal);
  end % switch powerVal

elseif baseVal==5
  
  switch powerVal
    case 2
      tap(1).No=[4,3];
      tap(2).No=[3,2];
      tap(3).No=[2,2];
      tap(4).No=[1,3];
    case 3
      tap(1).No=[0,2,3];
      tap(2).No=[4,1,2];
      tap(3).No=[3,0,2];
      tap(4).No=[3,4,2];
      tap(5).No=[3,3,3];
      tap(6).No=[3,3,2];
      tap(7).No=[3,1,3];
      tap(8).No=[2,0,3];
      tap(9).No=[2,4,3];
      tap(10).No=[2,3,3];
      tap(11).No=[2,3,2];
      tap(12).No=[2,1,2];
      tap(13).No=[1,0,2];
      tap(14).No=[1,4,3];
      tap(15).No=[1,1,3];
    case 4
      tap(1).No=[0,4,3,3];
      tap(2).No=[0,4,3,2];
      tap(3).No=[0,4,2,3];
      tap(4).No=[0,4,2,2];
      tap(5).No=[0,1,4,3];
      tap(6).No=[0,1,4,2];
      tap(7).No=[0,1,1,3];
      tap(8).No=[0,1,1,2];
      tap(9).No=[4,0,4,2];
      tap(10).No=[4,0,3,2];
      tap(11).No=[4,0,2,3];
      tap(12).No=[4,0,1,3];
      tap(13).No=[4,4,4,2];
      tap(14).No=[4,3,0,3];
      tap(15).No=[4,3,4,3];
      tap(16).No=[4,2,0,2];
      tap(17).No=[4,2,1,3];
      tap(18).No=[4,1,1,2];
      tap(19).No=[3,0,4,2];
      tap(20).No=[3,0,3,3];
      tap(21).No=[3,0,2,2];
      tap(22).No=[3,0,1,3];
      tap(23).No=[3,4,3,2];
      tap(24).No=[3,3,0,2];
      tap(25).No=[3,3,3,3];
      tap(26).No=[3,2,0,3];
      tap(27).No=[3,2,2,3];
      tap(28).No=[3,1,2,2];
      tap(29).No=[2,0,4,3];
      tap(30).No=[2,0,3,2];
      tap(31).No=[2,0,2,3];
      tap(32).No=[2,0,1,2];
      tap(33).No=[2,4,2,2];
      tap(34).No=[2,3,0,2];
      tap(35).No=[2,3,2,3];
      tap(36).No=[2,2,0,3];
      tap(37).No=[2,2,3,3];
      tap(38).No=[2,1,3,2];
      tap(39).No=[1,0,4,3];
      tap(40).No=[1,0,3,3];
      tap(41).No=[1,0,2,2];
      tap(42).No=[1,0,1,2];
      tap(43).No=[1,4,1,2];
      tap(44).No=[1,3,0,3];
      tap(45).No=[1,3,1,3];
      tap(46).No=[1,2,0,2];
      tap(47).No=[1,2,4,3];
      tap(48).No=[1,1,4,2];
    otherwise
      error('M-sequence %.0f^%.0f is not defined',baseVal,powerVal);
  end % switch powerVal
  
elseif baseVal==7
  
  switch powerVal
    case 2
      tap(1).No=[1,4];
    case 3
      tap(1).No=[0,1,5];
    case 4
      tap(1).No=[0,1,1,4];
    otherwise
      error('M-sequence %.0f^%.0f is not defined',baseVal,powerVal);
  end % switch powerVal
  
elseif baseVal==8
  
  switch powerVal
    case 2
      tap(1).No=[1,2];
    case 3
      tap(1).No=[1,0,3];
    case 4
      tap(1).No=[1,0,0,5];
    otherwise
      error('M-sequence %.0f^%.0f is not defined',baseVal,powerVal);
  end % switch powerVal

elseif baseVal==9
  
  switch powerVal
    case 2
      tap(1).No=[1,3];
    case 3
      tap(1).No=[0,1,3];
    case 4
      tap(1).No=[1,0,0,6];
    otherwise
      error('M-sequence %.0f^%.0f is not defined',baseVal,powerVal);
  end %switch powerVal
  
elseif baseVal==11
  
  switch powerVal
    case 2
      tap(1).No=[10,4];
      tap(2).No=[12,4];
      tap(3).No=[1,3];
      tap(4).No=[3,3];
      tap(5).No=[8,3];
      tap(6).No=[10,3];
      tap(7).No=[12,3];
      tap(8).No=[1,4];
      tap(9).No=[4,4];
      tap(10).No=[7,4];
      tap(11).No=[2,5];
      tap(12).No=[3,5];
      tap(13).No=[8,5];
      tap(14).No=[9,5];
      tap(15).No=[4,9];
      tap(16).No=[5,9];
      tap(17).No=[6,9];
      tap(18).No=[7,9];
    case 3
      tap(1).No=[0,10,7];
    case 4
      tap(1).No=[0,0,10,9];
    otherwise
      error('M-sequence %.0f^%.0f is not defined',baseVal,powerVal);
  end % switch powerVal
  
elseif baseVal==13
  
  switch powerVal
    case 2
      tap(1).No=[12,11];
    case 3
      tap(1).No=[0,12,7];
    otherwise
      error('M-sequence %.0f^%.0f is not defined',baseVal,powerVal);
  end % switch powerVal

end % if baseVal


%% construct m-sequence

% set the initial sequence
ms=zeros(bitNum,1);
if isempty(whichSeq), whichSeq=ceil(rand(1)*length(tap));
else 
  if whichSeq>length(tap) || whichSeq<1
    disp(' wrapping arround!');
    whichSeq=rem(whichSeq,length(tap))+1;
  end
end

% weights
weights=zeros(1,powerVal);
if baseVal==2
    weights(tap(whichSeq).No)=1;
elseif baseVal>2
   weights=tap(whichSeq).No;
end

% set user-defined tap
if exist('user_taps','var')
  if ~isempty(user_taps), weights = user_taps; end
end

% generate the sequence
for i=1:bitNum
  % calculating next digit with modulo powerVal arithmetic
  % register, (tap(1).No)
  
  %ms(i)=rem(sum(register(tap(whichSeq).No)),baseVal);
  if baseVal == 4 || baseVal == 8 || baseVal == 9
    % operation for power of prime base
    tmp = 0;
    for ind = 1:(length(weights))
      tmp = qadd(tmp,qmult(weights(ind),register(ind),baseVal),baseVal);
    end
    ms(i) = tmp;
  else % operation for prime bases
    ms(i)=rem(weights*register+baseVal,baseVal);
  end
  
  % updating the register
  register=[ms(i);register(1:powerVal-1)];
end

% shift the generated sequence
ms=ms(:);
if ~isempty(shift),
  shift=rem(shift, length(ms));
  ms=[ms(shift+1:end); ms(1:shift)];
end

% balance the sequence
if balance_flag
  if baseVal==2  
    ms=ms*2-1;
  elseif baseVal==3
    ms(ms==2)=-1;
  elseif baseVal==4 
    ms(ms==3)=-1;
    ms(ms==2)=-2;
    ms(ms==1)=2;
    ms(ms==0)=1;
  elseif baseVal==5 
    ms(ms==4)=-1;
    ms(ms==3)=-2;
  elseif baseVal==7
    ms(ms==6)=-1;
    ms(ms==5)=-2;
    ms(ms==4)=-3;
  elseif baseVal==8
    ms(ms==7)=-1;
    ms(ms==6)=-2;
    ms(ms==5)=-3;
    ms(ms==4)=-4;
    ms(ms==3)=4;
    ms(ms==2)=3;
    ms(ms==1)=2;
    ms(ms==0)=1;
  elseif baseVal==9
    ms(ms==8)=-1;
    ms(ms==7)=-2;
    ms(ms==6)=-3;
    ms(ms==5)=-4;
  elseif baseVal==11
    ms(ms==10)=-1;
    ms(ms==9)=-2;
    ms(ms==8)=-3;
    ms(ms==7)=-4;
    ms(ms==6)=-5;
  elseif baseVal==13
    ms(ms==12)=-1;
    ms(ms==11)=-2;
    ms(ms==10)=-3;
    ms(ms==9)=-4;
    ms(ms==8)=-5;
    ms(ms==7)=-6;
  else
    error('wrong baseVal!');
  end
end
