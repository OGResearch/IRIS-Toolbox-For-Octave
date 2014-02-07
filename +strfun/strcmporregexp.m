function Inx = strcmporregexp(List,String)
% strcmporregexp  Match string by plain comparison or by regexp engine.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(regexp(String,'[^\w]','once'))
    Inx = strcmp(List,String);
else
    start = regexp(List,String,'once');
    Inx = ~cellfun(@isempty,start);
end

end