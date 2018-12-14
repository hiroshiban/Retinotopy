% compare auto-correlations between M-sequnce & MT19937's rondom array

clear all; close all;

% set base etc.
base=2;
power=8;
slength=base^power-1;

% repetitions
rept=1;

% initialize random seed
if ~exist('RandStream','file')
  % run old method
  rand('twister',sum(100*clock)); %#ok
  cseed='';
else
  % new method
  cseed = RandStream.create('mt19937ar','seed',sum(100*clock));
  %cseed = RandStream.create('mrg32k3a','seed',sum(100*clock));
  RandStream.setDefaultStream(cseed);
end


% msequence
ms=zeros(rept,slength);
macorr=zeros(rept,2*slength-1);
for ii=1:1:rept
  %ms(ii,:)=mseq(base,power,1,mod(ii,15)+1,1)';
  ms(ii,:)=mseq(base,power,1,14,1)';
  
  % calculate auto-correlations
  %macorr(ii,:)=xcorr(ms(ii,:),slength,'coeff');
  for jj=1:1:slength-1
    macorr(ii,jj)=corr(ms(ii,:)',shift(ms(ii,:),-(slength-jj))');
  end
  macorr(ii,slength)=corr(ms(ii,:)',ms(ii,:)');
  for jj=1:1:slength-1
    macorr(ii,slength+1+jj)=corr(ms(ii,:)',shift(ms(ii,:),jj)');
  end
  
end
mcmean=mean(macorr,1);
%mcmean(round(numel(mcmean)/2))=[];

% random
rnd=zeros(rept,slength);
racorr=zeros(rept,2*slength-1);
for ii=1:1:rept
  tmp=randi(2,[1,slength])-1;
  tmp(tmp==0)=-1;
  rnd(ii,:)=tmp;
  
  % calculate auto-correlations
  %racorr(ii,:)=xcorr(rnd(ii,:),slength,'coeff');
  for jj=1:1:slength-1
    racorr(ii,jj)=corr(rnd(ii,:)',shift(rnd(ii,:),-(slength-jj))');
  end
  racorr(ii,slength)=corr(rnd(ii,:)',rnd(ii,:)');
  for jj=1:1:slength-1
    racorr(ii,slength+1+jj)=corr(rnd(ii,:)',shift(rnd(ii,:),jj)');
  end
  
end
mrmean=mean(racorr,1);
%mrmean(round(numel(mrmean)/2))=[];

% plot the result
figure('MenuBar','none'); hold on;
L2=plot(mrmean,'g-','LineWidth',2);
L1=plot(mcmean,'b-','LineWidth',2);

legend([L1,L2],'m-sequence','MT19937');

set(gca,'XLim',[0,2*slength-1]);
set(gca,'XTick',[1,slength,2*slength-1]);
set(gca,'XTickLabel',[-slength+1 0 slength-1]);

set(gca,'YLim',[-0.4,1.2]);
set(gca,'YTick',-0.4:0.2:1.2);
set(gca,'YTickLabel',-0.4:0.2:1.2);

title('auto-correlation against the lag');
