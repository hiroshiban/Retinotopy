function isFieldResult = isstructmember(inStruct, fieldName)

% Checks whether the target struct contains a filed you specified as a member.
% function isFieldResult = isstructmember(inStruct, fieldName)
% 
% [about]
% This function checks whether fieldName is a member of inStruct.
% Returns 1 if fieldName exists in inStruct. Returns 0 if not.
% Will be useful to control {if} & {while} loops.
%
% [example]
% >> test.name='HB'
% >> isstructmember(test,name)
% >> ans =
% >>       1
% >> isstructmember(test,weight)
% >> ans =
% >>       0
%
% [input]
% inStruct  : struct to be checked (struct)
% fieldName : string of a member name 
%
% [output]
% 1 -- true
% 0 -- false
%
%
% Created    : "2010-06-09 15:50:54 ban"
% Last Update: "2013-11-22 23:34:15 ban (ban.hiroshi@gmail.com)"

isFieldResult = 0;
f = fieldnames(inStruct(1));
for i=1:length(f)
  if(strcmp(f{i},strtrim(fieldName)))
    isFieldResult = 1;
    return;
  elseif isstruct(inStruct(1).(f{i}))
    isFieldResult = isstructmember(inStruct(1).(f{i}), fieldName);
    if isFieldResult
      return;
    end
  end
end
