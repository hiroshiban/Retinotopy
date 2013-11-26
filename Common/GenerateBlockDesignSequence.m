function [design,p_val]=GenerateBlockDesignSequence(num_conds,num_repeat,num_check_history,rand_init_flag,efficiency_flag)

% Generates a pseudo-random sequence for Block-design fMRI experiment.
% function [design,p_val]=GenerateBlockDesignSequence(num_conds,num_repeat,
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
%                     p_val would normally satisfy < 0.05
%                     However, if repetition of random number gen exceeds
%                     1000 times, p_val would be > 0.05
%
% [NOTE]
% This function consumes less CPU power than GenerateRandomDesignSequence does.
% For event-related fMRI design, use M-sequence generator instead.
%
% Created: Feb 23 2010 Hiroshi Ban
% Last Update: "2013-11-22 23:10:22 ban (ban.hiroshi@gmail.com)"


%%% check input variables
if nargin < 2, help GenerateBlockDesignSequence; return; end
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
design=zeros(1,num_conds*num_repeat);

% set the first one (this is always random without any overlapping)
currentSeq=randperm(num_conds);
tmpStorage=currentSeq;
design(1:num_conds)=currentSeq;

repeat_flag=1; h=1; rep=0;
% re-generate the rest of sequence until h(=RUNS test's null hypothesis)
% is rejected or the number of repetition reaches 1000
while (h && rep<1000) && repeat_flag

  % repetitions
  rep=rep+1;

  % initialize the first sequence
  currentSeq=tmpStorage;

  for ii=1:1:num_repeat-1
    % set the current start/end positions, used for indexing
    spos=num_conds*ii;
    epos=num_conds*(ii+1);

    % select the first few sequence considering the preceding presentation history
    tmp1=shuffle(currentSeq(1:end-num_check_history));
    tmp1=tmp1(1:num_check_history);

    % delete the elements selected above
    [null,idx]=intersect(currentSeq,tmp1);
    currentSeq(idx)=[];

    % shuffle the rests
    tmp2=shuffle(currentSeq);

    % combine the elements to a new sequence and set it to the design array
    design(1+spos:epos)=[tmp1 tmp2];

    % update the current sequence
    currentSeq=design(1+spos:epos);
  end

  %fprintf('design: %s\n',num2str(design)); % for DEBUG

  % evaluate the generated sequence using RUNS test, alpha=0.05
  [h,p_val]=runstest(design,median(design),'alpha',0.05);

  % exit if efficiency_flag is not set
  if ~efficiency_flag, repeat_flag=0; end

end % while (~h && rep<1000) && repeat_flag


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
