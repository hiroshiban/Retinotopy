classdef eventlogger

% a class to handle event log for your bahavior/fMRI/TMS experiments.
%
% [method]
% >> [event,reference_time]=event.set_reference_time(reference_time) : set reference time point for the event logs
% >> [reference_time,event]=event.get_reference_time()               : get reference time point for the event logs
% >> [event,eventcounter]=event.set_eventcounter(num)                : set the current event ID (num=1,2,3,...)
% >> [eventcounter,event]=event.get_eventcounter()                   : get the current event ID
% >> event=event.add_event(name,parameter,specific_time,display_flg) : add new event to the object
% >> [all_event_cell,event]=event.get_event()                        : get event log from the object
% >> [my_event_cell,event]=event.get_A_event(names_parameters)       : get event log(s) with name(s)/parameter(s) you want to extract
% >> [numTasks,numHits,numErrors,numResponses,RT,event]=event.calc_accuracy(correct_event)    : calculate task accuracy
% >> [numTasks,numHits,numErrors,numResponses,RT,event]=event.calc_accuracies(correct_events) : calculate multiple selection task accuracies
%
% [about input/output variables]
% reference_time : reference time point to be used in logging the latter event time.
%                  e.g. reference_time=GetSecs();
% event          : record of the events, cell structure. each of cell has 3 elements below.
%                  {event_time(GetSecs()-reference_time),name_of_the_event,parameter_of_the_event}
% name           : name of the event you want to add
% parameter      : parameter of the event you want to add
% all_event_cell : cell structure that contains {event_time,name_of_the_event,parameter_of_the_event}
% my_event_cell  : cell structure that only contains names and parameters you specified
% names_parameters : cell structure of the event names and/or parameters. For example,
%                    when you use get_A_event with names_parameters={'stim 1','stim 2','Responses'},
%                    only the event structures with 'stim 1', 'stim2', or 'Responses' will be returned
%                    from the whole event data structure.
% correct_event  : string (or cell structure) to indicate the correct response(s) for the task event
%                  e.g. correct_event={'key1','key2'}; (both key1 and key2 are the correct answer.)
% correct_events : cell structure to indicate the combination of task IDs and the corresponding correct responses
%                  e.g. correct_event{1}={1,'key1'}; correct_event{2}={2,'key2'};
% numTasks       : the number of tasks in the event array
% numHits        : the number of hit responses in the event array
% numErrors      : the number of error responses in the event array
% numResponses   : the number of total participant's responses
% RT             : reaction times
%
%
% Created    : "2013-11-17 21:42:27 ban"
% Last Update: "2016-10-21 16:20:32 ban"

properties (Hidden) %(SetAccess = protected)
  eventcounter=1; % a counter for event logging
  ref_time=0;     % base time point to log the event time
  event=[];       % cell array to store the event logs
end

methods

  % constructor
  function obj=eventlogger(base_t,eventcounter)
    if nargin>=1 && ~isempty(base_t), obj.ref_time=base_t; end
    if nargin==2 && ~isempty(eventcounter), obj.eventcounter=eventcounter; end
  end

  % destructor
  function obj=delete(obj)
    % do nothing
  end

  % set reference time point for the event log
  function [obj,reference_time]=set_reference_time(obj,reference_time)
    obj.ref_time=reference_time;
  end

  % get reference time point for the event log
  function [reference_time,obj]=get_reference_time(obj)
    reference_time=obj.ref_time;
  end

  % set the current event ID (1,2,3,...)
  function [obj,eventcounter]=set_eventcounter(num)
    obj.eventcounter=num;
    eventcounter=num;
  end

  % get the current event ID (1,2,3,...)
  function [eventcounter,obj]=get_eventcounter(obj)
    eventcounter=obj.eventcounter;
  end

  % add new event to the eventlogger object
  function obj=add_event(obj,name,parameter,specific_time,display_flg)
    if nargin<2 || isempty(name), name=''; end
    if nargin<3 || isempty(parameter), parameter=[]; end
    if nargin<4 || isempty(specific_time)
      obj.event{obj.eventcounter,1}=GetSecs()-obj.ref_time;
    else
      obj.event{obj.eventcounter,1}=GetSecs()-specific_time;
    end
    if nargin<5 || isempty(display_flg), display_flg=0; end
    obj.event{obj.eventcounter,2}=name;
    obj.event{obj.eventcounter,3}=parameter;
    if display_flg
      fprintf('[% 4.4f] %15s   %s\n',...
              obj.event{obj.eventcounter,1},...
              obj.event{obj.eventcounter,2}(1:min(15,numel(obj.event{obj.eventcounter,2}))),...
              num2str(obj.event{obj.eventcounter,3}));
    end
    obj.eventcounter=obj.eventcounter+1;
  end

  % get event log from the eventlogger object
  function [event,obj]=get_event(obj)
    event=obj.event;
  end

  % get event log with a name you want to extract alone
  function [event,obj]=get_A_event(obj,names_parameters)
    if nargin<2 || isempty(names_parameters)
      event=obj.event;
      return
    end

    if ~iscell(names_parameters), names_parameters={names_parameters}; end
    event=[];
    counter=0;
    for ii=1:1:size(obj.event,1)
      for jj=1:1:length(names_parameters)
        if strfind(obj.event{ii,2},names_parameters{jj}) || strfind(obj.event{ii,3},names_parameters{jj})
          counter=counter+1;
          event{counter,1}=obj.event{jj,1}; %#ok
          event{counter,2}=obj.event{jj,2}; %#ok
          event{counter,3}=obj.event{jj,3}; %#ok
        end
      end
    end
  end

  % calculate task accuracy
  function [numTasks,numHits,numErrors,numResponses,RT,obj]=calc_accuracy(obj,correct_event)
    % count the number of subject's responses
    numResponses=0;
    for ii=1:length(obj.event)-1
      if (strcmp(obj.event{ii,2}, 'Response')), numResponses=numResponses + 1; end
    end

    % calculate Hit rate
    numTasks=0; numHits=0; numErrors=0; RT=[];
    for ii=1:length(obj.event)
      % check subject responses
      if strfind(obj.event{ii,2},'Task')
        numTasks=numTasks+1;
        for jj=ii+1:1:length(obj.event)
          if strfind(obj.event{jj,2},'Task') % check observer responses: whether observer responded before the next task event occured
            RT(numTasks)=NaN; %#ok
            numErrors=numErrors+1;
            break
          elseif ischar(obj.event{jj,3}) && ismember(obj.event{jj,3},correct_event)
            RT(numTasks)=obj.event{jj,1}-obj.event{ii,1}; %#ok
            numHits=numHits+1;
            break
          elseif jj==length(obj.event) % reach to the end of the event array.
            RT(numTasks)=NaN; %#ok
            numErrors=numErrors+1;
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
    % not use nanmedian() as it never compute median value when the number of NaN exceeds the half of the elemnts of the array.
    disp(['Median RT (Hit) : ',num2str(median(RT(~isnan(RT)))*1000),' ms']);
    disp('******************************');
  end

  % calculate multiple selection task accuracies
  function [numTasks,numHits,numErrors,numResponses,RT,obj]=calc_accuracies(obj,correct_events)
    % count the number of subject's responses
    numResponses=0;
    for ii=1:length(obj.event)-1
      if (strcmp(obj.event{ii,2}, 'Response')), numResponses=numResponses + 1; end
    end

    eventIDs=zeros(1,length(correct_events));
    for ii=1:1:length(correct_events), eventIDs(ii)=correct_events{ii}{1}; end

    % calculate Hit rate
    numTasks=zeros(1,length(correct_events));
    numHits=zeros(1,length(correct_events));
    numErrors=zeros(1,length(correct_events));
    RT=cell(1,length(correct_events));
    for ii=1:length(obj.event)-1
      % check subject responses
      if strfind(obj.event{ii,2},'Task')
        idx=find(eventIDs==obj.event{ii,3});
        if ~isempty(idx)
          numTasks(idx)=numTasks(idx)+1;
          for jj=ii+1:1:length(obj.event)-1
            if strfind(obj.event{jj,2},'Task') % check observer responses: whether observer responded before the next task event occured
              RT{idx}=[RT{idx},NaN];
              numErrors(idx)=numErrors(idx)+1;
              break
            elseif strcmp(obj.event{jj,2},'Response')
              if strcmp(obj.event{jj,3},correct_events{idx}{2}) % correct response
                RT{idx}=[RT{idx},obj.event{jj,1}-obj.event{ii,1}];
                numHits(idx)=numHits(idx)+1;
                break
              else % incorrect response
                RT{idx}=[RT{idx},NaN];
                numErrors(idx)=numErrors(idx)+1;
                break
              end
            end
          end
        end % if ~isempty(idx)
      end
    end

    % displaying the results
    disp('******************************');
    disp(['Total Tasks     : ',num2str(sum(numTasks))]);
    disp(['Total Responses : ',num2str(sum(numResponses))]);
    disp(['Hit Rate        : ',num2str(sum(numHits)/sum(numTasks)*100),'%']);
    %disp(['False alarms    : ',num2str(numResponses-sum(numHits))]);
    RTs=cell2mat(RT);
    % not use nanmedian() as it never compute median value when the number of NaN exceeds the half of the elemnts of the array.
    disp(['Median RT (Hit) : ',num2str(median(RTs(~isnan(RTs)))*1000),' ms']);
    disp('******************************');

    % plotting the results
    figure; hold on;
    h1=plot(numHits./numTasks.*100,'ro-','LineWidth',2);  % hits
    h2=plot(numErrors./numTasks.*100,'bo-','LineWidth',1); % false alarms

    title('Behavior detection accuracies');
    legend([h1,h2],'Hit Rate','FalseAlarm Rate');
    set(gca,'XLim',[0,length(correct_events)+1]);
    set(gca,'XTick',0:length(correct_events)+1);
    set(gca,'XTickLabel',{'',1:length(correct_events),''});
    set(gca,'YLim',[0,100]);
    set(gca,'YTick',0:10:100);
    set(gca,'YTickLabel',0:10:100);
    xlabel('task type');
    ylabel('Percentage (%)');
  end

end % methods

end % classdef eventlogger
