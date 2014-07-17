function X = myeval(This,varargin)
% myeval  [Not a public function] Numerically evaluate sydney.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(This.func)
    if isnumeric(This.args)
        X = This.args;
        return
    else
        X = NaN;
    end
else
    args = This.args;
    for i = 1 : length(args)
        args{i} = myeval(args{i},varargin{:});
    end
    X = feval(This.func,args{:});
end

end
