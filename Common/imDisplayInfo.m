function [img,fnames]=imDisplayInfo(tgt_dir,img_ext,img_inc_prefix,img_exc_prefix,save_flg)

% Reads images in the target directory and displays their pixel intensities.
% function [img,fnames]=imDisplayInfo(tgt_dir,:img_ext,:img_inc_prefix,:img_exc_prefix,:save_flg)
% (: is optional)
%
% This function reads images and display their pixel intensity histgrams and FFT power.
%
% [input]
% tgt_dir        : target directory that includes images you want to process.
%                  should set with a relative path format, e.g. tgt_dir='../images/image01';
% img_ext        : image file extension(s), cell structure or string. '.jpg' by default
% img_inc_prefix : image file prefix(s) that is to be included in processing,
%                  cell structure or string, '*' by default.
% img_exc_prefix : image file prefix(s) that is to be excluded from processing,
%                  cell structure or string, empty by default.
% save_flg       : whether saving the converted image [0|1]. 0 by default.
%
% [output]
% img            : FFT (when input images are grayscale) or the original images, cell structure
% fnames         : the corresponding file names that are converted.
%
%
% Created    : "2013-11-14 16:56:48 ban"
% Last Update: "2013-11-22 23:15:54 ban (ban.hiroshi@gmail.com)"

% check input variables
if nargin<1 || isempty(tgt_dir), help(mfilename()); return; end
if nargin<2 || isempty(img_ext), img_ext='.jpg'; end
if nargin<3 || isempty(img_inc_prefix), img_inc_prefix='*'; end
if nargin<4 || isempty(img_exc_prefix), img_exc_prefix=''; end
if nargin<5 || isempty(save_flg), save_flg=0; end

if ~iscell(img_ext), img_ext={img_ext}; end
if ~iscell(img_inc_prefix), img_inc_prefix={img_inc_prefix}; end
if ~iscell(img_exc_prefix), img_exc_prefix={img_exc_prefix}; end

if save_flg, save_prefix='_fft'; end

% set prefix correctly
for ii=1:1:length(img_ext)
  if ~strcmp(img_ext{ii}(1),'.'), img_ext{ii}=['.',img_ext{ii}]; end
end

% check target directory
tgt_dir=fullfile(pwd,tgt_dir);
if ~exist(tgt_dir,'dir'), error('can not find taget directory. check input variable.'); end

fprintf('target: %s\n',tgt_dir);

% get image files
fprintf('displaying image information...\n');
scrsz = get(0,'ScreenSize');
hcolors={[1,0,0],[0,1,0],[0,0,1]};
img=''; fnames=''; img_counter=0;
for ii=1:1:length(img_ext)
  for jj=1:1:length(img_inc_prefix)
    tmpfnames=wildcardsearch(tgt_dir,[img_inc_prefix{jj},img_ext{ii}]);
    for kk=1:1:length(tmpfnames)

      % check whether the target image is excluded from processing
      exc_flg=0;
      for mm=1:1:length(img_exc_prefix)
        if ~isempty(img_exc_prefix{mm}) && strfind(tmpfnames{kk},img_exc_prefix{mm}), exc_flg=1; break; end
      end
      if exc_flg, continue; end

      img_counter=img_counter+1;
      img{img_counter}=imread(tmpfnames{kk});

      % set figure
      [path,fname,ext]=fileparts(tmpfnames{kk});
      fprintf('processing: %s%s...',fname,ext);
      f1=figure('Name',sprintf('%s%s: histgram and FFT power plots',fname,ext),...
                'Position',[scrsz(3)/7,scrsz(4)/8,5*scrsz(3)/7,6*scrsz(4)/8],...
                'Color',[0.9,0.9,0.9],'NumberTitle','off');

      % get pixel intensity histgram
      sz=size(img{img_counter},3);
      subplot(2,2,[1,3]); hold on;
      if sz==1
        hist(double(img{img_counter}(:)),255);
        h=findobj(gca,'Type','Patch');
        set(h,'FaceColor',[0.7,0.7,0.7],'EdgeColor',[0.7,0.7,0.7]);
        legend(h,'grayscale');
      else
        h=zeros(1,3);
        for pp=1:1:size(img{img_counter},3)
          tgt=img{img_counter}(:,:,pp);
          [ndata,bins]=hist(double(tgt(:)),255);
          h(pp)=bar(bins,ndata,'hist');
          set(h(pp),'FaceColor',hcolors{pp},'EdgeColor',hcolors{pp},'FaceAlpha',0.3,'EdgeAlpha',0.3);
        end
        legend(h,{'red','green','blue'});
      end
      title(strrep(sprintf('pixel intensity: %s%s',fname,ext),'_','\_'));
      set(gca,'XLim',[0,255]);
      set(gca,'XTick',[1,50,100,150,200,250]);
      set(gca,'XTickLabel',[1,50,100,150,200,250]);
      xlabel('pixel intensity');
      ylabel('the number of pixels');

      % plot the original image
      subplot(2,2,2); hold on;
      imshow(img{img_counter},[0,255]); axis equal; axis off;
      title(strrep(sprintf('original image: %s%s',fname,ext),'_','\_'));

      % get 2D image FFT
      if numel(size(img{img_counter}))~=3 % if the target is not a RGB image
        % apply 2D FFT
              img{img_counter}=abs(fftshift(fft2(double(img{img_counter})))); % fftshift sets DC component to the center, point symmetric

        subplot(2,2,4); hold on;
        % NOTE. In image FFT, high peaks at the center (DC component) often hide details.
        % Reduce these contrast with the log function.
        imshow(log(1+img{img_counter}),[]); axis equal;
        title(strrep(sprintf('FFT power: %s%s',fname,ext),'_','\_'));
        colorbar();
      end

      if save_flg
        set(gcf,'PaperPositionMode','auto');
        print(f1,fullfile(path,[fname,save_prefix,'.png']),'-dpng','-r0');
      end

      fnames{img_counter}=tmpfnames{kk};
      pause(0.5);
      close all;
      disp('done.');

    end
  end
end
disp('completed.');

return
