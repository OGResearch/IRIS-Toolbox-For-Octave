function This = parse(Func,varargin)
% parse  [Not a public function] Convert Matlab function to sydney object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

persistent SYDNEY;

if isnumeric(SYDNEY)
    SYDNEY = sydney();
end

%--------------------------------------------------------------------------

This = SYDNEY;
This.func = Func;

if strcmp(Func,'sydney.d');
    This.numd.func = char(varargin{1});
    This.numd.wrt = varargin{2};
    varargin(1:2) = [];
end

nArg = length(varargin);
This.lookahead = false(1,nArg);
a = varargin;
for iArg = 1 : nArg
    if isnumeric(a{iArg})
        % This argument is a plain number.
        x = varargin{iArg};
        a{iArg} = SYDNEY;
        a{iArg}.args = x;
        This.lookahead(iArg) = false;
    else
        This.lookahead(iArg) = any(a{iArg}.lookahead);
    end
end
This.args = a;

end