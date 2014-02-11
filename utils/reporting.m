function D = reporting(Inp,D,Range,varargin)
% reporting  Run reporting equations.
%
% Syntax
% =======
%
%     D = reporting(FName,D,Range,...)
%
% Input arguments
% ================
%
% * `FName` [ char ] - Name of the reporting equation file.
%
% * `D` [ struct ] - Input database that will be used to evaluate the
% reporting equations.
%
% * `Range` [ numeric ] - Date range on which the reporting equations will
% be evaluated.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database with reporting variables.
%
% Options
% ========
%
% * `'dynamic='` [ *`true`* | `false` ] - If `true` equations will be evaluated
% period by period allowing for own lags; if `false`, equations will be
% evaluated once for all periods.
%
% * `'merge='` [ *`true`* | `false` ] - Merge output database with input
% datase.
%
% Description
% ============
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

default = {...
    'dynamic',true,@islogical,...
    'merge',true,@islogical,...
    };
opt = passvalopt(default,varargin{:});

%--------------------------------------------------------------------------

if ischar(Inp)
    % Preparse reporting equation file.
    p = preparser(Inp);
    % Save carry-around packages.
    preparser.export('reporting',p.Export);
    % Parse reporting code.
    This = reporting(p);
elseif isstruct(Inp)
    This = Inp;
else
    utils.error('reporting', ...
        'Invalid type of input argument(s).');
end

if ~isstruct(This) || isempty(This) || ~isfield(This,'lhs') ...
        || isempty(This.lhs)
    return
end

% Remove time subscripts from non-tseries field names in the equations.
list = fieldnames(D);
for i = 1 : length(list)
    if ~is.tseries(D.(list{i})) && ~any(strcmp(This.lhs,list{i}))
        This.rhs = strrep(This.rhs,sprintf('d.%s(t,:)',list{i}),sprintf('d.%s',list{i}));
    end
end

% Pre-allocate time series and assign comments.
for i = 1 : length(This.lhs)
    if ~isfield(D,This.lhs{i})
        D.(This.lhs{i}) = tseries();
    end
    if ~isempty(This.label{i})
        D.(This.lhs{i}) = comment(D.(This.lhs{i}),This.label{i});
    end
end

if opt.dynamic
    % Evaluate equations recursively period by period.
    fn = cell(size(This.rhs));
    for iRhs = 1 : length(This.rhs)
        fn{iRhs} = str2func(['@(d,t)',This.rhs{iRhs}]);
    end
    Range = Range(:).';
    for t = Range
        for i = 1 : length(This.rhs)
            name = This.lhs{i};
            try
                x = fn{i}(D,t);
            catch %#ok<CTCH>
                x = NaN;
            end
            if ~isnumeric(x)
                x = This.nan{i};
            else
                x(isnan(x)) = This.nan{i};
            end
            tmpsize = size(D.(This.lhs{i}));
            if length(tmpsize) == 2 && tmpsize(2) == 1 && length(x) > 1
                D.(name) = xxScalar2nd(D.(name),size(x));
            end
            D.(name)(t,:) = x;
        end
    end
else
    % Evaluate equations once for all periods.
    for i = 1 : length(This.rhs)
        This.rhs = strrep(This.rhs,'(t,:)','{range,:}');
        try
            x = eval(This.rhs{i});
        catch Error
            x = NaN;
            utils.warning('reporting',...
                ['Error evaluating ''%s''.\n', ...
                '\tMatlab says: %s'],...
                This.userRHS{i},Error.message);
        end
        D.(This.lhs{i}) = x;
    end
end

if ~opt.merge
    D = D * This.lhs;
end

end

% Subfunctions.

%**************************************************************************
function This = xxScalar2nd(This,NewSize)

s = size(This.data);
if length(s) > 2 || s(2) > 1
    return
end
n = prod(NewSize(2:end));
This.data = This.data(:,ones(1,n));
This.data = reshape(This.data,[s(1),NewSize(2:end)]);
This.Comment = This.Comment(1,ones(1,n));
This.Comment = reshape(This.Comment,[1,NewSize(2:end)]);

end %% xxScalar2nd().