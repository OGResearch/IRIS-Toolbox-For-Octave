function [index,match,tokens] = matchindex(list,pattern)

if isstruct(list)
   list = fieldnames(list);
end

%**************************************************************************

if ~iscell(list)
   list = {list};
end
if isempty(pattern)
   index = false(size(list));
   match = {};
   tokens = {};
   return
end
if pattern(1) ~= '^'
   pattern = ['^',pattern];
end
if pattern(end) ~= '$'
   pattern = [pattern,'$'];
end
if nargout > 2
   [match,tokens] = regexp(list,pattern,'once','match','tokens');
else
   match = regexp(list,pattern,'once','match');
end
index = ~cellfun(@isempty,match);
match = match(index);
if nargout > 2
   tokens = tokens(index);
end

end