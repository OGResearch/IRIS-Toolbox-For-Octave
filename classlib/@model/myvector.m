function Vec = myvector(This,varargin)
% myvector  [Not a public function] Vectors of variables in the state space.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ischar(varargin{1})
    type = lower(varargin{1});
    switch type
        case 'y'
            % Vector of measurement variables.
            inx = This.nametype == 1;
            Vec = This.name(inx);
            Vec = xxWrapInLog(Vec,This.log(inx));
        case 'x'
            % Vector of transition variables.
            pos = real(This.solutionid{2});
            shift = imag(This.solutionid{2});
            Vec = This.name(pos);
            for i = find(shift ~= 0)
                Vec{i} = sprintf('%s{%g}',Vec{i},shift(i));
            end
            Vec = xxWrapInLog(Vec,This.log(pos));
        case 'e'
            % Vector of shocks.
            inx = This.nametype == 3;
            Vec = This.name(inx);
    end
else
    pos = real(varargin{1});
    shift = imag(varargin{1});
    Vec = This.name(pos);
    for i = find(shift ~= 0)
        Vec{i} = sprintf('%s{%g}',Vec{i},shift(i));
    end
    Vec = xxWrapInLog(Vec,This.log(pos));
end

end

% Subfunctions.

%**************************************************************************
function Vec = xxWrapInLog(Vec,Log)

for i = find(Log)
    Vec{i} = sprintf('log(%s)',Vec{i});
end

end
% xxWrapInLog().
