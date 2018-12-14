function [numTasks,numHits,numErrors,numResponses,RT]=CalculateDetectionTaskAccuracies(event,correct_event)

% Gathers subject's responses and computes performances of multiple-detection/identification tasks.
% function [numTasks,numHits,numErrors,RT]=CalculateDetectionTaskAccuracies(event,correct_event)
%
% Calculates subject's responses and accuracies through the experiment
%
% [note]
% The difference between CalculateDetectionTaskAccuracy and CalculateDetectionTaskAccuracies
% CalculateDetectionTaskAccuracy  : use when a single task sequence is applied.
% CalculateDetectionTaskAccuracies: use when multiple sequences and the corresponding multiple responses are obtained.
%
% [input]
% event  : cell structure in which all the stimulus presentation protocols and responses
%          are stored. each cell of event structure contains 3 elemtns, and should be
%          {event_time, event_name, comment/record}
%          For details, please see AddEvent.m
% correct_events : cell structure to indicate the combination of task IDs and the corresponding correct responses
%                  e.g. correct_event{1}={1,'key1'}; correct_event{2}={2,'key2'};
%
% [output]
% numTasks  : the number of tasks, [1 x correct_event] matrix
% numHits   : the number of hit (correct) responses, [1 x correct_event] matrix
% numErrors : the number of error responses, [1 x correct_event] matrix
%
%
% Created    : "2013-11-11 12:04:42 ban"
% Last Update: "2013-11-22 18:17:21 ban (ban.hiroshi@gmail.com)"

% check input variable
if nargin<1 || isempty(event), help(mfilename()); end

% count the number of subject's responses
numResponses=0;
for ii=1:length(event)-1
  if (strcmp(event{ii,2}, 'Response')), numResponses=numResponses + 1; end
end

eventIDs=zeros(1,length(correct_event));
for ii=1:1:length(correct_event), eventIDs(ii)=correct_event{ii}{1}; end

% calculate Hit rate
numTasks=zeros(1,length(correct_event));
numHits=zeros(1,length(correct_event));
numErrors=zeros(1,length(correct_event));
RT=cell(1,length(correct_event));
for ii=1:length(event)-1
  % check subject responses
  if strfind(event{ii,2},'Task')
    idx=find(eventIDs==event{ii,3});
    numTasks(idx)=numTasks(idx)+1;
    for jj=ii+1:1:length(event)-1
      if strfind(event{jj,2},'Task') % check observer responses: whether observer responded before the next task event occured
        RT{idx}=[RT{idx},NaN];
        numErrors(idx)=numErrors(idx)+1;
        break
      elseif strcmp(event{jj,2},'Response')
        if strcmp(event{jj,3},correct_event{idx}{2}) % correct response
          RT{idx}=[RT{idx},event{jj,1}-event{ii,1}];
          numHits(idx)=numHits(idx)+1;
          break
        else % incorrect response
          RT{idx}=[RT{idx},NaN];
          numErrors(idx)=numErrors(idx)+1;
          break
        end
      end
    end
  end
end

% displaying the results
disp('******************************');
disp(['Total Tasks     : ',num2str(sum(numTasks))]);
disp(['Total Responses : ',num2str(sum(numResponses))]);
disp(['Hit Rate        : ',num2str(sum(numHits)/sum(numTasks)*100),'%']);
%disp(['False alarms    : ',num2str(numResponses-sum(numHits))]);
disp(['Median RT (Hit) : ',num2str(nanmedian(cell2mat(RT))*1000),' ms']);
disp('******************************');

% plotting the results
figure; hold on;
h1=plot(numHits./numTasks.*100,'ro-','LineWidth',2);  % hits
h2=plot(numErrors./numTasks.*100,'bo-','LineWidth',1); % false alarms

title('Behavior detection accuracies');
legend([h1,h2],'Hit Rate','FalseAlarm Rate');
set(gca,'XLim',[0,length(correct_event)+1]);
set(gca,'XTick',0:length(correct_event)+1);
set(gca,'XTickLabel',{'',1:length(correct_event),''});
set(gca,'YLim',[0,100]);
set(gca,'YTick',0:10:100);
set(gca,'YTickLabel',0:10:100);
xlabel('task type');
ylabel('Percentage (%)');

return
