function This = instrument(This,varargin)
% instrument  Define forecast conditioning instruments in VAR models.
%
% Syntax to add forecast instruments
% ===================================
%
%     V = instrument(V,Def)
%     V = instrument(V,Name,Expr)
%     V = instrument(V,Name,Vec)
%
% Syntax to remove all forecast instruments
% ==========================================
%
%     V = instrument(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object to which forecast instruments will be added.
%
% * `Def` [ char | cellstr ] - Definition of the new forecast conditioning
% instrument.
%
% * `Name` [ char ] - Name of the new forecast conditiong instrument.
%
% * `Expr` [ char ] - Expression defining the new forecast conditiong
% instrument.
%
% * `Vec` [ numeric ] - Vector of coeffients to combine the VAR variables
% to create the new forecast conditioning instrument.
%
% Output arguments
% =================

% * `V` [ VAR ] - VAR object with forecast instruments added or removed.
%
% Description
% ============
%
% Conditioning instruments allow you to compute forecasts conditional upon
% a linear combinationi of endogenous variables.
%
% The definition strings must have the following form:
%
%     'name := expression'
%
% where `name` is the name of the new conditioning instrument, and
% `expression` is an expression referring to existing VAR variable names
% and/or their lags.
%
% Alternatively, you can separate the name and the expression into two
% input arguments. Or you can define the instrument by a vector of
% coefficients, either `1`-by-`N` or `1`-by-`(N+1)`, where `N` is the
% number of variables in the VAR object `V`, and the last optional element
% is a constant term (set to zero if no value supplied).
%
% The conditioning instruments must be a linear combination (possibly with
% a constant) of the existing endogenous variables and their lags up to p-1
% where p is the order of the VAR. The names of the conditioning
% instruments must be unique (i.e. distinct from the names of endogenous
% variables, residuals, exogenous variables, and existing instruments).
%
% Example
% ========
%
% In the following example, we assume that the VAR object `v` has at least
% three endogenous variables named `x`, `y`, and `z`.
%
%     V = instrument(V,'i1 := x - x{-1}','i2: = (x + y + z)/3');
%
% Note that the above line of code is equivalent to
%
%     V = instrument(V,'i1 := x - x{-1}');
%     V = instrument(V,'i2: = (x + y + z)/3');
%
% The command defines two conditioning instruments named `i1` and `i2`. The
% first instrument is the first difference of the variable `x`. The second
% instrument is the average of the three endogenous variables.
%
% To impose conditions (tunes) on a forecast using these instruments, you
% run [`VAR/forecast`](VAR/forecast) with the fourth input argument
% containing a time series for `i1`, `i2`, or both.
%
%     j = struct();
%     j.i1 = tseries(startdate:startdate+3,0);
%     j.i2 = tseries(startdate:startdate+3,[1;1.5;2]);
%
%     f = forecast(v,d,startdate:startdate+12,j);
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if isempty(varargin)
    % Clear conditioning instruments.
    This.INames = {};
    This.Zi = [];
    return
end

%--------------------------------------------------------------------------

if isempty(This.YNames)
    utils.error('VAR:instrument', ...
        ['Cannot create instruments in VAR objects ', ...
        'without named variables.']);
end

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);

if p == 0
    utils.error('VAR:instrument', ...
        ['Cannot create instruments in empty or 0-th order ', ...
        'VAR objects.']);
end

if iscellstr(varargin) ...
        && all(cellfun(@(x) ~isempty(strfind(x,':=')),varargin))
    % V = instrument(V,'Name := Expression');
    nName = length(varargin);
    Name = cell(1,nName);
    Exprn = cell(1,nName);
    List = varargin;
    doParseNameExprn();
elseif iscellstr(varargin(1:2:end))
    % V = instrument(V,'Name',Vec);
    % V = instrument(V,'Name','Expression');
    Name = strtrim(varargin(1:2:end));
    Exprn = varargin(2:2:end);
    nName = length(Name);
    List = cell(1,nName);
    List(:) = {''}; % TODO
else
    utils.error('VAR:instrument', ...
        'Invalid definition(s) of VAR instrument(s).');
end

xVector = {};
doXVector();
doChkNames();

Z = zeros(nName,ny*p);
C = zeros(nName,1);

% Index of RHS expression strings.
charInx = cellfun(@ischar,Exprn);

% Convert RHS expression strings to vectors, and include them in the `Z`
% matrix.
[Zi,Ci,isValid] = preparser.lincomb2vec(Exprn(charInx),xVector);
if any(~isValid)
    utils.error('VAR:instrument', ...
        ['This is not a valid definition string', ...
        'for conditioning instruments: ''%s''.'], ...
        List{~isValid});
end
Z(charInx,:) = Zi;
C(charInx,:) = Ci;

% Include RHS vectors in the `Z` matrix.
for i = find(~charInx)
    e = Exprn{i}(:).';
    if length(e) == ny
        Z(i,1:ny) = e;
    elseif length(e) == ny+1
        Z(i,1:ny) = e(1:ny);
        C(i,:) = e(ny+1);
    elseif length(e) == p*ny+1
        Z(i,1:p*ny) = e(1:p*ny);
        C(i,:) = e(p*ny+1);
    else
        utils.error('VAR:instrument', ...
            ['Incorrect size of the vector of coefficients ', ...
            'for this instrument: ''%s''.'], ...
            Name{i});
    end
end

doChkExprn();

This.INames = [This.INames,Name];
This.IEqtn = [This.IEqtn,List];

% The constant term is placed first in Zi, but last in user inputs/outputs.
This.Zi = [This.Zi;[C,Z]];


% Nested functions...


%**************************************************************************

    
    function doParseNameExprn()
        List = regexprep(List,'\s+','');
        List = regexprep(List,';$','','once');
        if ismatlab
            List = regexprep(List,'.*','$0;','once');
        else
            List = strcat(List,';');
        end
        List = regexprep(List,'(?<!:)=',':=','once');
        validDef = true(1,nName);
        for ii = 1 : nName
            tok = regexp(List{ii}, ...
                '^([a-zA-Z]\w+):?=(.*);?$','tokens','once');
            if length(tok) == 2 ...
                    && ~isempty(tok{1}) && ~isempty(tok{2})
                Name{ii} = tok{1};
                Exprn{ii} = tok{2};
            else
                validDef(ii) = false;
            end
        end
        if any(~validDef)
            utils.error('VAR:instrument', ...
                ['This is not a valid definition string', ...
                'for conditioning instruments: ''%s''.'], ...
                List{~validDef});
        end
    end % doParseNameExprn()


%**************************************************************************


    function doXVector()
        xVector = This.YNames;
        for ii = 1 : p-1
            time = sprintf('{-%g}',ii);
            if ismatlab
                temp = regexprep(This.YNames,'.*',['$0',time]);
            else
                temp = strcat(This.YNames,time);
            end
            xVector = [xVector,temp]; %#ok<AGROW>
        end
    end % doXVector()


%**************************************************************************

    
    function doChkNames()
        isUnique = true(1,nName);
        isValid = true(1,nName);
        chkList = [This.YNames,This.XNames,This.ENames,This.INames];
        for ii = 1 : nName
            isUnique(ii) = ~any(strcmp(Name{ii},chkList));
            isValid(ii) = isvarname(Name{ii});
            chkList = [chkList,Name{ii}]; %#ok<AGROW>
        end
        if any(~isUnique)
            utils.error('VAR:instrument', ...
                ['This name already exists ', ...
                'in the ',class(This),' object: ''%s''. '], ...
                Name{~isUnique});            
        end
        if any(~isValid)
            utils.error('VAR:instrument', ...
                ['This is not a valid name ', ...
                'for conditioning instruments: ''%s''.'], ...
                Name{~isValid});
        end
    end % doChkNames()


%**************************************************************************
 
    
    function doChkExprn()
        validexprsn = all(~isnan([C,Z]),2);
        if any(~validexprsn)
            utils.error('VAR:instrument', ...
                ['Defition of this conditioning instrument ', ...
                'is invalid: ''%s''.'], ...
                Name{~validexprs});
        end
    end % doChkExprn()


end