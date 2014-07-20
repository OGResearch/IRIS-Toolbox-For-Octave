function Flag = islog(This,Name)
% islog  True for log-linearised variables.
%
% Syntax
% =======
%
%     Flag = islog(M,Name)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `Name` [ char | cellstr ] - Name or names of model variable(s).
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True for log variables.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Parse input arguments.
pp = inputParser();
pp.addRequired('name',@(x) ischar(x) || iscellstr(x));
pp.parse(Name);

if ischar(Name)
    Name = regexp(Name,'\w+','match');
end

%--------------------------------------------------------------------------

Flag = false(size(Name));
valid = true(size(Name));
for i = 1 : length(Name)
    ix = strcmp(This.name,Name{i});
    if any(ix)
        Flag(i) = This.IxLog(ix);
    else
        valid(i) = false;
    end
end

if any(~valid)
    utils.error('model:islog', ...
        ['This name does not exist ', ...
        'in the model object: ''%s''.'], ...
        Name{~valid});
end

end
