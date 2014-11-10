classdef AddSlide2PPT

% Matlab class to generate PowerPoint 2007 slides
%
% [example]
% >> imgs=wildcardsearch(fullfile(pwd,'imgs'),'*.png'); % get PNG images as cell structure
% >> ppt=AddSlide2PPT();
% >> ppt=ppt.addTitleSlide('add image test',getusername());
%
% >> % add 1 images on a slide
% >> tgt1=imgs{1};
% >> ppt=ppt.addImageSlide('1 image',tgt1);
%
% >> % add 2 images on a slide
% >> tgt2{1}=imgs{1};
% >> tgt2{2}=imgs{2};
% >> ppt=ppt.addImageSlide('2 images',tgt2);
%
% >> % add 4 images
% >> tgt4{1}=imgs{1};
% >> tgt4{2}=imgs{2};
% >> tgt4{3}=imgs{4};
% >> tgt4{4}=imgs{5};
% >> ppt=ppt.addImageSlide('4 images',tgt4);
% >> ppt=ppt.saveAs(fullfile(pwd,'test_add_image.ppt'));
% >> clear all; close all;
%
% Modified by Hiroshi Ban for Mcalibrator2 and PlotVOItSeriesVTC
% Multiple images can be pasted in a slide
% Image sizes and positions are automatically adjusted.
%
%
% Created    : "2013-04-16 02:45:40 banh"
% Last Update: "2014-10-01 11:47:25 ban"

%layout types:
% 1 - title
% 2 - title and content
% 3 - section header
% 4 - Two Content
% 5 - Comparison
% 6 - Title only
% 7 - blank
% 8 - content with caption
% 9 - picture with caption
% 10 -title and vertical text
% 11 - vertical title and text

properties
  app_handle
  presentation
  pt = 0.0352; %point size in cm.
  newline = char(13); %the new line character.
end

methods
    function obj = AddSlide2PPT()
    %creates a new presentation. You must have powerpoint
    %2007 open first.
    try
      obj.app_handle = actxserver('PowerPoint.Application'); %open powerpoint
    catch
      obj.app_handle=[];
      return;
    end
    obj.presentation = obj.app_handle.Presentation.Add; %create presentation
    end

    function obj = addTitleSlide(obj, title_text, sub_title_text)
    %creates a title slide
    %   ppt = ppt.addTitleSlide(title_text, sub_title_text)
    %       title_text - the text to put in the title section.
    %       sub_title_text - the text to put in the sub title
    %       section.
    %
    % If you need to use a line break (start a new line) use the
    % ppt.newline field of this object. (aka char(13)).

    %create slide
    layout = obj.presentation.SlideMaster.CustomLayouts.Item(1); %title slide layout
    Slide = obj.presentation.Slides.AddSlide(obj.presentation.Slides.Count + 1,layout);

    %do title
    if exist('title_text', 'var') && ~isempty(title_text)
      Slide.Shapes.Item(1).TextFrame.TextRange.Text = title_text;
    end

    %do sub-title
    if exist('sub_title_text', 'var') && ~isempty(sub_title_text)
      Slide.Shapes.Item(2).TextFrame.TextRange.Text = sub_title_text;
    end
    end

    function obj = addTextSlide(obj, title_text, main_text)
    %creates a section title slide
    %   ppt = ppt.addTitleSlide(title_text, main_text)
    %       title_text - the text to put in the title section.
    %       main_text - the text to put in the sub title
    %       section.
    %
    % If you need to use a line break (start a new line) use the
    % ppt.newline field of this object. (aka char(13)).

    %create slide
    layout = obj.presentation.SlideMaster.CustomLayouts.Item(2); %section header
    Slide = obj.presentation.Slides.AddSlide(obj.presentation.Slides.Count + 1,layout);

    %do title
    if exist('title_text', 'var') && ~isempty(title_text)
      tb = Slide.Shapes.Item(1);
      tb.TextFrame.TextRange.Text = title_text;
      tb.TextFrame.TextRange.Font.Size=24;
    end

    %do footer
    if exist('main_text', 'var') && ~isempty(main_text)
      tb2 = Slide.Shapes.Item(2);
      tb2.TextFrame.TextRange.Text = main_text;
      tb2.TextFrame.TextRange.Font.Size=18;
    end
    end

    function obj = addImageSlide(obj, title_text, image_file, nrows, ncols, margin)
    %creates a slide consisting of only a title and an image
    %   ppt = ppt.addImageOnlySlide(title_text, image_file)
    %       title_text - the text to put in the title section.
    %       image_file - the filename(s) and path(s) of the image(s) to use
    %                    1 file name or cell structure of file names

    %create slide
    layout = obj.presentation.SlideMaster.CustomLayouts.Item(2); %title and content
    Slide = obj.presentation.Slides.AddSlide(obj.presentation.Slides.Count + 1,layout);

    if nargin<7 || isempty(margin), margin=0; end

    %do title
    textH=0;
    if exist('title_text', 'var') && ~isempty(title_text)
      Slide.Shapes.Item(1).top=10;
      Slide.Shapes.Item(1).height=30;
      Slide.Shapes.Item(1).TextFrame.TextRange.Text = title_text;
      Slide.Shapes.Item(1).TextFrame.TextRange.Font.Size=24;

      % get text field size
      textH=Slide.Shapes.Item(1).top+Slide.Shapes.Item(1).height;
    end

    %do image
    if exist('image_file', 'var') && ~isempty(image_file)

      if ~iscell(image_file), image_file={image_file}; end

      if nargin<5 || isempty(nrows), nrows=ceil(sqrt(length(image_file))); end
      if nargin<6 || isempty(ncols), ncols=ceil(length(image_file)/nrows); end
      if nrows>ncols, tmp=ncols; ncols=nrows; nrows=tmp; clear tmp; end

      % get whole slide canvas size
      H=obj.presentation.SlideMaster.Height;
      H=H-textH;
      W=obj.presentation.SlideMaster.Width;

      for mm=1:1:length(image_file)

        % set margins at top/bottom/left/right
        cH=H/nrows;
        cW=W/ncols;

        % get image size
        timg=imread(image_file{mm});
        sz=size(timg);
        iH=sz(1); iW=sz(2);

        % calculate best image field
        resizeratio=linspace(1.0,0.0,100);
        for ii=1:1:numel(resizeratio)
          tH=iH*resizeratio(ii);
          tW=iW*resizeratio(ii);
          if tH<cH && tW<cW, break; end
        end
        iH=tH; iW=tW;

        % get the final position of the image
        ccol=mod(mm,ncols); if ~ccol, ccol=ncols; end;
        crow=floor((mm-ccol)/ncols)+1;

        left=(cW-2*margin-iW)/2+margin+(ccol-1)*cW;
        top=(cH-2*margin-iH)/2+textH+margin+(crow-1)*cH;

        % add picture
        opicture=Slide.Shapes.AddPicture(image_file{mm},'msoFalse','msoTrue',left,top,iW,iH);

        % NOTE: new PowerPoint doesn't allow us to directly use VBA or ActivX-object to insert
        %       a picture at whatever size it'd come in at were we to do the same job manually.
        if obj.app_handle.Version>15 % PowerPoint version 15.0 or above.
          opicture.Left=left;
          opicture.Top=top;
          opicture.Width=iW;
          opicture.Height=iH;
        end

      end % for mm=1:1:length(image_file)

    end
    end

    function obj = saveAs(obj, filename)
    %saves the presentation to the specified file
    obj.presentation.SaveAs(filename);
    end

    function obj = close(obj, noQuit)
    %closes the presentation.
    %   close(noQuit)
    %       noQuit - if false function will attempt
    %       to close powerpoint if no presentations remain open.

    if ~exist('noQuit', 'var') || (exist('noQuit', 'var') && isempty(noQuit))
      noQuit = true;
    end

    obj.presentation.Close;
    if ~noQuit && obj.app_handle.Presentations.Count <= 0
      obj.app_handle.Quit;
    end
    obj.app_handle.delete;
    end
end

end
