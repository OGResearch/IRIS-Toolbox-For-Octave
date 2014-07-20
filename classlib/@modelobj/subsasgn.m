function This = subsasgn(This,S,B)
% subsasgn  Subscripted assignment for model and systemfit objects.
%
% Syntax for assigning parameterisations from other object
% =========================================================
%
%     M(Inx) = N
%
% Syntax for deleting specified parameterisations
% ================================================
%
%     M(Inx) = []
%
% Syntax for assigning parameter values or steady-state values
% =============================================================
%
%     M.Name = X
%     M(Inx).Name = X
%     M.Name(Inx) = X
%
% Syntax for assigning std deviations or cross-correlations of shocks
% ====================================================================
%
%     M.std_Name = X
%     M.corr_Name1__Name2 = X
%
% Note that a double underscore is used to separate the Names of shocks in
% correlation coefficients.
%
% Input arguments
% ================
%
% * `M` [ model | systemfit ] - Model or systemfit object that will be assigned new
% parameterisations or new parameter values or new steady-state values.
%
% * `N` [ model | systemfit ] - Model or systemfit object compatible with `M` whose
% parameterisations will be assigned (copied) into `M`.
%
% * `Inx` [ numeric ] - Inx of parameterisations that will be assigned
% or deleted.
%
% * `Name`, `Name1`, `Name2` [ char ] - Name of a variable, shock, or
% parameter.
%
% * `X` [ numeric ] - A value (or a vector of values) that will be assigned
% to a parameter or variable Named `Name`.
%
% Output arguments
% =================
%
% * `M` [ model | systemfit ] - Model or systemfit object with newly assigned or deleted
% parameterisations, or with newly assigned parameters, or steady-state
% values.
%
% Description
% ============
%
% Example
% ========
%
% Expand the number of parameterisations in a model or systemfit object
% that has initially just one parameterisation:
%
%     m(1:10) = m;
%
% The parameterisation is simply copied ten times within the model or
% systemfit object.
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if ~ismodel(This) || (~ismodel(B) && ~isempty(B) && ~isnumeric(B))
    utils.error('modelobj:subsasgn', ...
        'Invalid subscripted reference or assignment to model object.');
end

%--------------------------------------------------------------------------

nAlt = size(This.Assign,3);

% Fast dot-reference assignment `This.Name = X`
%-----------------------------------------------
if isnumeric(B) ...
        && (numel(B) == 1 || numel(B) == nAlt) ...
        && numel(S) == 1 && S(1).type == '.'
    name = S(1).subs;
    Assign = This.Assign;
    [assignPos,stdcorrPos] = mynameposition(This,{name});
    if isnan(assignPos) && isnan(stdcorrPos)
        utils.error('modelobj:subsasgn', ...
            'This name does not exist in the model object: ''%s''.', ...
            name);
    elseif ~isnan(assignPos)
        Assign(1,assignPos,:) = B;
    else
        This.stdcorr(1,stdcorrPos,:) = B;
    end
    This.Assign = Assign;
    return
end

nAlt = size(This.Assign,3);
S = xxAlterSubs(S,nAlt);

% Regular assignment
%--------------------

% `This(Inx) = B`,
% `B` must be model or empty.

if any(strcmp(S(1).type,{'()','{}'}))
    
    if ~ismodel(B) && ~isempty(B)
        utils.error('modelobj:subsasgn', ...
            'Invalid subscripted reference or assignment to model object.');
    end
    
    % Make sure the LHS and RHS model objects are compatible in yvector,
    % xvector, and evector.
    if ismodel(B) && ~iscompatible(This,B)
        utils.error('modelobj:subsasgn', ...
            ['Objects A and B are not compatible in ', ...
            'in subscripted assignment A( ) = B.']);
    end
    
    AInx = S(1).subs{1};
    
    % `This([]) = B` leaves `This` unchanged.
    if isempty(AInx)
        return
    end
    
    nAInx = length(AInx);
    
    if ismodel(B) && ~isempty(B)
        % `This(Inx) = B`
        % where `B` is a non-empty model whose length is either 1 or the same as
        % the length of `This(Inx)`.
        nb = size(B.Assign,3);
        if nb == 1
            BInx = ones(1,nAInx);
        else
            BInx = ':';
            if nAInx ~= nb && nb > 0
                utils.error('modelobj:subsasgn', ...
                    ['Number of parameterisations on LHS and RHS ', ...
                    'of assignment to model object must be the same.']);
            end
        end
        This = mysubsalt(This,AInx,B,BInx);
    else
        % `This(Inx) = []` or `This(Inx) = B`
        % where `B` is an empty model.
        This = mysubsalt(This,AInx,[]);
    end
    
elseif strcmp(S(1).type,'.')
    % `This.Name = B` or `This.Name(Inx) = B`
    % `B` must be numeric.
    
    name = S(1).subs;
    
    % Find the position of the Name in the Assign vector or stdcorr
    % vector.
    [assignPos,stdcorrPos] = mynameposition(This,{name});
    
    % Create `Inx` for the third dimension.
    if length(S) > 1
        % `This.Name(Inx) = B`
        Inx2 = S(2).subs{1};
    else
        % `This.Name = B`
        Inx2 = ':';
    end

    % Assign the value or throw an error.
    if ~isnan(assignPos)
        This.Assign(1,assignPos,Inx2) = B;
    elseif ~isnan(stdcorrPos)
        This.stdcorr(1,stdcorrPos,Inx2) = B;
    else
        utils.error('modelobj:subsasgn', ...
            'This name does not exist in the model object: ''%s''.', ...
            name);
    end

end

end


% Subfunctions...


%**************************************************************************


function S = xxAlterSubs(S,N)
% xxAlterSubs  Check and re-organise subscripted reference to objects with mutliple parameterisations.

% This function accepts the following subscripts
%     x(index)
%     x.name
%     x.(index)
%     x.name(index)
%     x(index).name(index)
% where index is either logical or numeric or ':'
% and returns
%     x(numeric)
%     x.name(numeric)

% Convert x(index1).name(index2) to x.name(index1(index2)).
if length(S) == 3 && any(strcmp(S(1).type,{'()','{}'})) ...
        && strcmp(S(2).type,{'.'}) ...
        && any(strcmp(S(3).type,{'()','{}'}))
    % convert a(index1).name(index2) to a.name(index1(index2))
    index1 = S(1).subs{1};
    if strcmp(index1,':')
        index1 = 1 : N;
    end
    index2 = S(3).subs{1};
    if strcmp(index2,':');
        index2 = 1 : length(index1);
    end
    S(1) = [];
    S(2).subs{1} = index1(index2);
end

% Convert a(index).name to a.name(index).
if length(S) == 2 && any(strcmp(S(1).type,{'()','{}'})) ...
        && strcmp(S(2).type,{'.'})
    S = S([2,1]);
end

if length(S) > 2
    utils.error('modelobj:subsasgn', ...
        'Invalid reference to model object.');
end

% Convert a(:) or a.name(:) to a(1:n) or a.name(1:n).
% Convert a(logical) or a.name(logical) to a(numeric) or a.name(numeric).
if any(strcmp(S(end).type,{'()','{}'}))
    if strcmp(S(end).subs{1},':')
        S(end).subs{1} = 1 : N;
    elseif islogical(S(end).subs{1})
        S(end).subs{1} = find(S(end).subs{1});
    end
end

% Throw error for mutliple indices
% a(index1,index2,...) or a.name(index1,index2,...).
if any(strcmp(S(end).type,{'()','{}'}))
    if length(S(end).subs) ~= 1 || ~isnumeric(S(end).subs{1})
        utils.error('modelobj:subsasgn', ...
            'Invalid reference to model object.');
    end
end

% Throw error if index is not real positive integer.
if any(strcmp(S(end).type,{'()','{}'}))
    index = S(end).subs{1};
    if any(index < 1) || any(round(index) ~= index) ...
            || any(imag(index) ~= 0)
        utils.error('modelobj:subsasgn', ...
            ['Subscript indices must be ', ...
            'either real positive integers or logicals.']);
    end
end

end % xxAlterSubs()
