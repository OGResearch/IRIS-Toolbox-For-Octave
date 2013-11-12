function X = subsref(This,S)
% subsref  Subscripted reference for model and systemfit objects.
%
% Syntax for retrieving object with subset of parameterisations
% ==============================================================
%
%     M(Inx)
%
% Syntax for retrieving parameters or steady-state values
% ========================================================
%
%     M.Name
%
% Syntax to retrieve a std deviation or a cross-correlation of shocks
% ====================================================================
%
%     M.std_ShockName
%     M.corr_ShockName1__ShockName2
%
% Note that a double underscore is used to separate the names of shocks in
% correlation coefficients.
%
% Input arguments
% ================
%
% * `M` [ model | systemfit ] - Model or systemfit object.
%
% * `Inx` [ numeric | logical ] - Inx of requested parameterisations.
%
% * `Name` - Name of a variable, shock, or parameter.
%
% * `ShockName1`, `ShockName2` - Name of a shock.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Fast reference `m.name`.
if strcmp(S(1).type,'.') && ischar(S(1).subs)
    name = S(1).subs;
    [assignpos,stdcorrpos] = mynameposition(This,{name});
    if isnan(assignpos) && isnan(stdcorrpos)
        utils.error(class(This), ...
            ['This name does not exist in the ',class(This), ...
            ' object: ''%s''.'], ...
            name);
    end
    if ~isnan(assignpos)
        % Regular parameter or steady state.
        X = permute(This.Assign(1,assignpos,:),[1,3,2]);
    else
        % Std or corr.
        X = permute(This.stdcorr(1,stdcorrpos,:),[1,3,2]);
    end
    S(1) = [];
    if ~isempty(S)
        X = subsref(X,S);
    end
elseif strcmp(S(1).type,'()') && length(S(1).subs) == 1 ...
        && isnumeric(S(1).subs{1})
    % m(Inx) or m{Inx}
    Inx = S(1).subs{1};
    nalt = size(This.Assign,3);
    if any(Inx > nalt)
        utils.error(class(This), ...
            'Inx exceeds the number of alternative parameterisations.');
    end
    X = mysubsalt(This,Inx);
    S(1) = [];
    if ~isempty(S)
        X = subsref(X,S);
    end
end

end