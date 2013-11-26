function [numTasks,numHits,numErrors,numResponses,RT]=CalculateDetectionTaskAccuracy(event,correct_event)

% Gathers subject's responses and computes performances of a single-detection/identification task.
% function [numTasks,numHits,numErrors,numResponses,RT]=CalculateDetectionTaskAccuracy(event,correct_event)
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
% correct_event : string (or cell structure) to indicate the correct response(s) for the task event
%                 e.g. correct_event={'key1','key2'}; (both key1 and key2 are the correct answer.)
%
% [output]
% numTasks  : the number of tasks
% numHits   : the number of hit (correct) responses
% numErrors : the number of error responses
%
%
% Created    : "2013-11-11 12:04:42 ban"
% Last Update: "2013-11-22 18:17:15 ban (ban.hiroshi@gmail.com)"

% check input variable
if nargin<1 || isempty(event), help(mfilename()); end

% count the number of subject's responses
numResponses=0;
for ii=1:length(event)-1
  if (strcmp(event{ii,2}, 'Response')), numResponses=numResponses + 1; end
end

% calculate Hit rate
numTasks=0; numHits=0; numErrors=0; RT=[];
for ii=1:length(event)-1
  % check subject responses
  if strfind(event{ii,2},'Task')
    numTasks=numTasks+1;
    for jj=ii+1:1:length(event)-1
      if strfind(event{jj,2},'Task') % check observer responses: whether observer responded before the next task event occured
        RT(numTasks)=NaN; %#ok
        numErrors=numErrors+1;
        break
      elseif ~isnumeric(event{jj,3}) && ismember(event{jj,3},correct_event)
        RT(numTasks)=event{jj,1}-event{ii,1}; %#ok
        numHits=numHits+1;
        break
      end
    end
  end
end

disp('******************************');
disp(['Total Tasks     : ',num2str(numTasks)]);
disp(['Total Responses : ',num2str(numResponses)]);
disp(['Hit Rate        : ',num2str((numHits/numTasks)*100),'%']);
disp(['False alarms    : ',num2str(numResponses-numHits)]);
disp(['Median RT (Hit) : ',num2str(nanmedian(RT)*1000),' ms']);
disp('******************************');

return
