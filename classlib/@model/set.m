function This = set(This,varargin)
% set  Change modifiable model object property.
%
% Syntax
% =======
%
%     M = set(M,Request,Value)
%     M = set(M,Request,Value,Request,Value,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `Request` [ char ] - Name of a modifiable model object property that
% will be changed.
%
% * `Value` [ ... ] - Value to which the property will be set.
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with the requested property or properties
% modified.
%
% Valid requests to model objects
% ================================
%
% Equation labels and aliases
% ----------------------------
%
% * `'yLabels='`, `'xLabels='`, `'dLabels='`, `'lLabels='` [ cellstr ] -
% Change the labels attached to, respectively, measurement equations (`y`),
% transition equations (`x`), deterministic trends (`d`), and dynamic links
% (`d`).
%
% * `'labels='` [ cell ] - Change the labels attached to all equations;
% needs to be a cellstr matching the size of `get(M,'labels')`.
%
% * `'yeqtnAlias='`, `'xeqtnAlias='`, `'deqtnAlias='`, `'leqtnAlias='` [
% cellstr ] - Change the aliases of, respectively, measurement equations
% (`y`), transition equations (`x`), deterministic trends (`d`), and
% dynamic links (`d`).
%
% * `'eqtnAlias='` [ cell ] - Change the aliases of all equations; needs to
% be a cellstr matching the size of `get(M,'eqtnAlias')`.
%
% Descriptions and aliases of variables, shocks, and parameters
% --------------------------------------------------------------
%
% * `'yDescript='`, `'xDescript='`, `'eDescript='`, `'pDescript='` [
% cellstr ] - Change the descriptions of, respectively, measurement
% variables (`y`), transition variables (`x`), shocks (`e`), and exogenous
% variables (`g`).
%
% * `'descript='` [ struct ] - Change the descriptions of all variables,
% parameters, and shocks; needs to be a struct (database) with fields
% corresponding to model names.
%
% * `'yAlias='`, `'xAlias='`, `'eAlias='`, `'pAlias='` [ cellstr ] - Change
% the aliases of, respectively, measurement variables (`y`), transition
% variables (`x`), shocks (`e`), and exogenous variables (`g`).
%
% * `'alias='` [ struct ] - Change the aliases of all variables,
% parameters, and shocks; needs to be a struct (database) with fields
% corresponding to model names.
%
% Other requests
% ---------------
%
% * `'nAlt='` [ numeric ] - Change the number of alternative
% parameterisations.
%
% * `'stdVec='` [ numeric ] - Change the whole vector of std deviations.
%
% * `'tOrigin='` [ numeric ] - Change the base year for computing
% deterministic time trends in measurement variables.
%
% * `'epsilon='` [ numeric ] - Change the relative differentiation step
% when computing Taylor expansion.
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('m',@ismodel);
pp.addRequired('name',@iscellstr);
pp.addRequired('value',@(x) length(x) == length(varargin(1:2:end-1)));
pp.parse(This,varargin(1:2:end-1),varargin(2:2:end));

%--------------------------------------------------------------------------

varargin(1:2:end-1) = strtrim(varargin(1:2:end-1));
nArg = length(varargin);
found = true(1,nArg);
validated = true(1,nArg);
for iArg = 1 : 2 : nArg
    [found(iArg),validated(iArg)] = ...
        doSet(lower(varargin{iArg}),varargin{iArg+1});
end

% Report queries that are not modifiable model object properties.
if any(~found)
    utils.error('model', ...
        'This is not a modifiable model object property: ''%s''.', ...
        varargin{~found});
end

% Report values that do not pass validation.
if any(~validated)
    utils.error('model', ...
        'The value for this property does not pass validation: ''%s''.', ...
        varargin{~validated});
end

% Subfunctions.

%**************************************************************************
    function [Found,Validated] = doSet(UsrQuery,Value)
        
        Found = true;
        Validated = true;
        query = model.myalias(UsrQuery);
        
        switch query
            
            case 'nalt'
                if isnumericscalar(Value) ...
                        && Value > 0 && Value == round(Value)
                    This = alter(This,Value);
                else
                    Validated = false;
                end
                
            case 'stdvec'
                ne = length(This.solutionid{3});
                nalt = size(This.Assign,3);
                if isnumeric(Value) && ...
                        (numel(Value) == ne || numel(Value) == ne*nalt)
                    if numel(Value) == ne
                        Value = Value(:).';
                        Value = Value(1,:,ones([1,nalt]));
                    elseif size(Value,3) == 1
                        Value = permute(Value,[3,1,2]);
                    end
                    This.Assign(1,1:ne,:) = Value;
                else
                    Validated = false;
                end
                
            case 'torigin'
                if isnumericscalar(Value) && Value == round(Value)
                    This.torigin = Value;
                else
                    Validated = false;
                end
                
            case 'userdata'
                This = userdata(This,Value);
                
            case 'epsilon'
                if isnumericscalar(Value) && Value > 0
                    This.epsilon = Value;
                else
                    Validated = false;
                end
                
            case {'label','eqtnalias'}
                if strcmp(query,'label')
                    prop = 'eqtnlabel';
                else
                    prop = 'eqtnalias';
                end
                if iscellstr(Value) ...
                        && length(Value) == length(This.(prop))
                    This.(prop)(:) = Value(:);
                else
                    Validated = false;
                end
                
            case {'ylabel','xlabel','dlabel','llabel', ...
                    'yeqtnalias','xeqtnalias','deqtnalias','leqtnalias'}
                if ~isempty(strfind(query,'label'))
                    prop = 'eqtnlabel';
                else
                    prop = 'eqtnalias';
                end
                empty = cellfun(@isempty,This.eqtn);
                inx = This.eqtntype == find(query(1) == 'yxdl') & ~empty;
                if iscellstr(Value) && length(Value) == sum(inx)
                    This.(prop)(inx) = Value;
                else
                    Validated = false;
                end
                
            case 'rlabel'
                if iscellstr(Value) ...
                        && length(Value) == length(This.outside.label)
                    This.outside.label = Value;
                else
                    Validated = false;
                end
                
            case {'descript','alias'}
                if strcmp(query,'descript')
                    prop = 'namelabel';
                else
                    prop = 'namealias';
                end
                if isstruct(Value)
                    for i = 1 : length(This.name)
                        if isfield(Value,This.name{i}) && ischar(Value.(This.name{i}))
                            This.(prop){i} = Value.(This.name{i});
                        end
                    end
                else
                    Validated = false;
                end
                
            case {'ydescript','xdescript','edescript','pdescript','gdescript', ...}
                    'yalias','xalias','ealias','palias','galias'}
                if ~isempty(strfind(query,'descript'))
                    prop = 'namelabel';
                else
                    prop = 'namealias';
                end
                inx = This.nametype == find(query(1) == 'yxepg');
                if iscellstr(Value) && length(Value) == sum(inx)
                    This.(prop)(inx) = Value;
                else
                    Validated = false;
                end
                
            otherwise
                Found = false;
                
        end
        
    end % doSet().

end