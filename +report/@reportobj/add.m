function This = add(This,Child,varargin)
% Go down this object and all its descendants and find the
% youngest among possible parents.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

par = [];
x = This;

Child.hInfo = This.hInfo;

while true
    if any(strcmpi(shortclass(x),Child.childof)) ...
            && accepts(x)
        par = x;
    end
    if isempty(x.children)
        break
    end
    x = x.children{end};
end

% `x` is now the last child in the last generation.
if ~isequal(par,[])
    % Set parent first so that it is available in `specargin` and `setoptions`.
    Child.parent = par;
    [Child,varargin] = specargin(Child,varargin{:});
    Child = setoptions(Child,par.options,varargin{:});    
    par.children{end+1} = Child;
else
    label1 = shortclass(Child);
    if ~isempty(Child.title)
        label1 = [label1,' ''',Child.title,''''];
    end
    label2 = shortclass(x);
    if ~isempty(x.title)
        label2 = [label2,' ''',x.title,''''];
    end
    utils.error('report',...
        'This is not the right place to add %s after %s.',...
        label1,label2);
end

end