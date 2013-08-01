function This = parse(Func,varargin)
% parse  [Not a public function] Convert Matlab function to sydney object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

persistent TEMP;
if ~isa(TEMP,'sydney')
    TEMP = sydney();
end

try %#ok<TRYNC>
    x = builtin(Func,varargin{:});
    if isnumeric(x)
        This = sydney(x);
        return
    end
end

n = length(varargin);
This = TEMP;
This.func = Func;
This.lookahead = cell(1,n);
a = varargin;
for i = 1 : n
    if isnumeric(varargin{i})
        value = varargin{i};
        a{i} = TEMP;
        a{i}.func  = '';
        a{i}.args = value;
    elseif isa(varargin{i},'sydney')
        if isempty(varargin{i}.func) && ischar(varargin{i}.args)
            This.lookahead{i} = {varargin{i}.args};
        else
            This.lookahead{i} = [varargin{i}.lookahead{:}];
        end
    end
end
This.args = a;

end