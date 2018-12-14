function [design,p_val]=GenerateRandomDesignSequence(num_conds,num_repeat,num_check_history,rand_init_flag,efficiency_flag)

% Generates a randomozed event array.
% function [design,p_val]=GenerateRandomDesignSequence(num_conds,num_repeat,
%                        :num_check_history,:rand_init_flag,:efficiency_flag)
%                                             (: is optional input variables)
%
% Generate pseudo random sequence for Block-design fMRI experiment.
% The preceding history of to-be-presented stimulus order is taken into
% account to prevent from the successive presentation of the same condition.
%
% [difference between GenerateBlockDesignSequence and GenerateRandomDesignSequence]
%
% GenerateBlockDesignSequence  : randomize "num_conds" sequence repeatedly
%                                so, the generated sequence from 4 conds will be
%                                | 1 4 2 3 | 4 2 1 3 | 2 1 3 4 | ...
% GenerateRandomDesignSequence : randomize whole sequence at once
%                                so, the generated sequence from 4 conds will be
%                                | 1 3 1 4 | 2 3 1 2 | 4 3 1 2 | ...
%
% [input]
% num_conds         : the number of conditions in the designile, [val]
% num_repeat        : the number of repetitions of each stimulus, [val]
% num_check_history : the number of preceding history (preceding stimulus
%                     sequence) to be taken into account, [val]
%                     This value should be smaller than num_conds
% rand_init_flag    : if 1, random seed is set in this function using
%                     the current time
% efficiency_flag   : if 1, the goodness of randomization will be evaluated
%                     by RUNS test and optimization will be conducted, [0/1]
%
% [output]
% design            : fMRI block design sequence
%                     matrix, [1,(num_conds*num_repeat)]
% p_val             : p-value of RUNS test
%                     When "efficiency_flag" is set to 1,
%                     p_val would normally satisfy < 0.05.
%                     However, if repetition of random number gen exceeds
%                     1000 times, p_val would be > 0.05
%
% [NOTE]
% This function consumes more CPU power than GenerateBlockDesignSequence does.
% For event-related fMRI design, use M-sequnce generator instead.
%
% Created: Feb 24 2010 Hiroshi Ban
% Last Update: "2013-11-22 23:07:16 ban (ban.hiroshi@gmail.com)"


%%% check input variables
if nargin < 2, help GenerateRandomDesignSequence; return; end
if nargin < 3, num_check_history=1; end
if nargin < 4, rand_init_flag=0; end
if nargin < 5, efficiency_flag=0; end

if num_repeat < 1, error('The variable "num_repeat" should be greater than or equal to 1'); end
if num_conds < num_check_history, error('The variable "num_check_history" should be smaller than "num_conds"'); end


%%% initialize random seed
if rand_init_flag
  if ~exist('RandStream','file')
    % run old method
    rand('twister',sum(100*clock)); %#ok
  else
    % new method
    cseed = RandStream.create('mt19937ar','seed',sum(100*clock));
    RandStream.setDefaultStream(cseed);
  end
end


%%% generate the random sequence
repeat_flag=1; h=1; rep=0;

% re-generate the sequence until h(=RUNS test's null hypothesis)
% is rejected or the number of repetition reaches 1000
while (h && rep<1000) && repeat_flag

  % repetitions
  rep=rep+1;

  % set the first few design sequence
  OK_flag=1;
  while OK_flag
    design=zeros(1,num_conds*num_repeat);
    tmp=shuffle(repmat(1:num_conds,1,num_repeat));
    design(1:num_check_history)=tmp(1:num_check_history);
    tmp(1:num_check_history)=[];
    if length(unique(design(1:num_check_history)))==num_check_history, OK_flag=0; end
  end

  idx=1+num_check_history; ii=0; jj=1;
  while find(design==0)

    if intersect(design(1+ii:num_check_history+ii),tmp(jj))
      % if the array does not reach the last, continue to generate the rest sequence
      if length(tmp) > num_check_history
        jj=jj+1;
        if jj>length(tmp)
          break;
        else
          continue;
        end
      % if the array reaches the last element, discard this sequence & regenerate new one
      else
        break;
      end
    else
      design(idx)=tmp(jj);
      tmp(jj)=[]; idx=idx+1; ii=ii+1; jj=1;
    end

    %fprintf('design: %s\n',num2str(design)); % for DEBUG

  end % while find(design==0)

  % final check of the sequence, this code is required to prevent from a error
  % for the preceding codes (#line 98-102,103-106)
  if find(design==0), rep=rep-1; continue; end

  % evaluate the generated sequence using RUNS test, alpha=0.05
  [h,p_val]=runstest(design,median(design),'alpha',0.05);

  % exit if efficiency_flag is not set
  if ~efficiency_flag, repeat_flag=0; end

end % while (~h && rep<1000) && repeat_flag


%%% ===== OLD method, not efficient, do not use =====
% %%% generate the random sequence
% design=zeros(1,num_conds*num_repeat);
% repeat_flag=1; h=0; rep=0;
%
% % re-generate the sequence until h(=RUNS test's null hypothesis)
% % is rejected or the number of repetition reaches 1000
% while (~h && rep<1000) && repeat_flag
%
%   % repetitions
%   rep=rep+1;
%
%   overlap_flag=1;
%   while overlap_flag
%
%     % set the design sequence
%     design=shuffle(repmat(1:num_conds,1,num_repeat));
%     %fprintf('design: %s\n',num2str(design)); % for DEBUG
%
%     % check the order considering the preceding history
%     if num_check_history
%       for ii=1:1:length(design)-2*num_check_history
%         common=intersect(design(ii:ii+num_check_history),...
%                          design(1+ii+num_check_history:min(1+ii+2*num_check_history,length(design))));
%         % if common element is found, exit loop and generate a design again
%         if ~isempty(common), break; end
%       end
%     else
%       common=[];
%     end
%
%     % if common = [empty matrix], exit loop
%     if isempty(common), overlap_flag=0; end
%
%   end % while overlap_flag
%
%   % evaluate the generated sequence using RUNS test, alpha=0.05
%   [h,p_val]=runstest(design,median(design),'alpha',0.05);
%
%   % exit if efficiency_flag is not set
%   if ~efficiency_flag, repeat_flag=0; end
%
% end % while (~h && rep<1000) && repeat_flag
%%% ===== OLD method, not efficient, do not use =====


%% subfunction
function [Y,index] = shuffle(X)
% [Y,index] = shuffle(X)
%
% Randomly sorts X.
% If X is a vector, sorts all of X, so Y = X(index).
% If X is an m-by-n matrix, sorts each column of X, so
% for j=1:n, Y(:,j)=X(index(:,j),j).

[null,index] = sort(rand(size(X)));
[n,m] = size(X);
Y = zeros(size(X));

if (n == 1 || m == 1)
  Y = X(index);
else
  for j = 1:m
    Y(:,j)  = X(index(:,j),j);
  end
end
