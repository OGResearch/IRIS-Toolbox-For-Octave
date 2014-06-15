function Flag = islog(This,Name)
% islog  True for log-linearised variables.
%
% Syntax
% =======
%
%     flag = islog(m,name)
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object.
%
% * `name` [ char | cellstr ] - Name or names of model variable(s).
%
% Output arguments
% =================
%
% * `flag` [ `true` | `false` ] - True for variables declared as log-linear in
% a non-linear model.
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
if ismatlab
pp.addRequired('m',@(isArg)is.model(isArg));
pp.addRequired('name',@(x) ischar(x) || iscellstr(x));
pp.parse(This,Name);
else
pp = pp.addRequired('m',@(isArg)is.model(isArg));
pp = pp.addRequired('name',@(x) ischar(x) || iscellstr(x));
pp = pp.parse(This,Name);
end

if ischar(Name)
    Name = regexp(Name,'\w+','match');
end

%--------------------------------------------------------------------------

Flag = false(size(Name));
valid = true(size(Name));
for i = 1 : length(Name)
    index = strcmp(This.name,Name{i});
    if any(index)
        Flag(i) = This.log(index);
    else
        valid(i) = false;
    end
end

if any(~valid)
    utils.error('model', ...
        ['This name does not exist ', ...
        'in the model object: ''%s''.'], ...
        Name{~valid});
end

end