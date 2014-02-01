function This = replace(This,Data,Start,Comment)
% replace  [Not a public function] Safely replace tseries object properties.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

This.data = Data;
if nargin > 2
    This.start = Start(1);
end
if nargin > 3 && (iscell(Comment) || ischar(Comment))
    if iscell(Comment)
        This.Comment = Comment;
    elseif ischar(Comment)
        tmpsize = size(This.data);
        This.Comment = cell([1,tmpsize(2:end)]);
        This.Comment(:) = {Comment};
    end
else
    s = size(This.data);
    s(1) = 1;
    This.Comment = cell(s);
    This.Comment(:) = {''};
end
This = mytrim(This);

end
