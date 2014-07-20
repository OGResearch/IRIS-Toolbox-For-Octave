function [outstrings,outtokens] = rexpn(inexpr,inpattern,n,varargin)
  
if nargin < 3
  error('rexpn requires 2 or more input arguments.');
end

if nargin > 3 && strcmp(varargin{1},'ignorecase')
  fn = @regexpi;
  varargin = varargin(1,2:end);  
else
  fn = @regexp;
end

[start,finish,tokens] = feval(fn,inexpr,inpattern,varargin{1,1:end});
outstrings = cell([1,length(start)]);
outtokens  = cell([n,length(start)]);
if ~isempty(start)
  [outstrings{1,:}] = deal('');
end
if ~isempty(start) && n > 0
  [outtokens{:,:}] = deal('');
end
for i = 1 : length(start)
  outstrings{1,i} = inexpr(start(i):finish(i));
  for j = 1 : min([n,size(tokens{i},1)])
    if all(tokens{i}(j,1:2) == [0,0])
      outtokens{j,i} = '';
    else
      outtokens{j,i}  = inexpr(tokens{i}(j,1):tokens{i}(j,2));
    end
  end
end

return