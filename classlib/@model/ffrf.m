function [F,List] = ffrf(This,Freq,varargin)
% ffrf  Filter frequency response function of transition variables to measurement variables.
%
% Syntax
% =======
%
%     [F,List] = ffrf(M,Freq,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object for which the frequency response function
% will be computed.
%
% * `Freq` [ numeric ] - Vector of frequencies for which the response
% function will be computed.
%
% Output arguments
% =================
%
% * `F` [ numeric ] - Array with frequency responses of transition
% variables (in rows) to measurement variables (in columns).
%
% * `List` [ cell ] - List of transition variables in rows of the `F`
% matrix, and list of measurement variables in columns of the `F` matrix.
%
% Options
% ========
%
% * `'include='` [ char | cellstr | *`Inf`* ] - Include the effect of the
% listed measurement variables only; `Inf` means all measurement variables.
%
% * `'exclude='` [ char | cellstr | *empty* ] - Remove the effect of the
% listed measurement variables.
%
% * `'maxIter='` [ numeric | *500* ] - Maximum number of iteration when
% computing the steady-state Kalman filter.
%
% * `'matrixFmt='` [ *`'namedmat'`* | `'plain'` ] - Return matrix `F` as
% either a [`namedmat`](namedmat/Contents) object (i.e. matrix with named
% rows and columns) or a plain numeric array.
%
% * `'select='` [ *`@all`* | char | cellstr ] - Return FFRF for selected
% variables only; `@all` means all variables.
%
% * `'tolerance='` [ numeric | *`1e-7`* ] - Convergence tolerance when
% computing the steady-state Kalman filter.
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
pp.addRequired('Freq',@isnumeric);
pp.parse(Freq);

% Parse options.
opt = passvalopt('model.ffrf',varargin{:});

if isequal(opt.include,Inf) && ~isempty(opt.exclude)
    opt.include = This.name(This.nametype == 1);
elseif ischar(opt.include)
    opt.include = regexp(opt.include,'\w+','match');
end

if ischar(opt.exclude)
    opt.exclude = regexp(opt.exclude,'\w+','match');
end

if ~isempty(opt.exclude) && ~isequal(opt.include,Inf)
    utils.error('model', ...
        'Options ''include='' and ''exclude='' cannot be combined.');
end

isSelect = ~isequal(opt.select,@all);
isNamedMat = strcmpi(opt.MatrixFmt,{'namedmat'});

% TODO: Implement the `'exclude='` option through the `'select='` option.

%--------------------------------------------------------------------------

ny = length(This.solutionid{1});
nx = length(This.solutionid{2});
nAlt = size(This.Assign,3);

% Index of the measurement variables included.
if isequal(opt.include,Inf)
    incl = true(1,ny);
else
    incl = setdiff(opt.include,opt.exclude);
    incl = myselect(This,'y',incl);
end

Freq = Freq(:)';
nFreq = length(Freq);
F = nan(nx,ny,nFreq,nAlt);

if ny > 0 && any(incl)
    doFfrf();
else
    utils.warning('model', ...
        'No measurement variables included in calculation of FFRF.');
end

% List of variables in rows and columns of `F`.
rowNames = This.solutionvector{2};
colNames = This.solutionvector{1};

% Select requested variables if requested.
if isSelect
    [F,pos] = namedmat.select(F,rowNames,colNames,opt.select);
    rowNames = rowNames(pos{1});
    colNames = colNames(pos{2});
end
List = {rowNames,colNames};

if true % ##### MOSW
    % Convert output matrix to namedmat object if requested.
    if isNamedMat
        F = namedmat(F,rowNames,colNames);
    end
else
    % Do nothing.
end


% Nested function...


%**************************************************************************
    
    
    function doFfrf()
        [flag,nanAlt] = isnan(This,'solution');
        for iAlt = find(~nanAlt)
            nUnit = mynunit(This,iAlt);
            [T,R,~,Z,H,~,U,Omega] = mysspace(This,iAlt,false);
            % Compute FFRF.
            F(:,:,:,iAlt) = ...
                freqdom.ffrf3(T,R,[],Z,H,[],U,Omega,nUnit, ...
                Freq,incl,opt.tolerance,opt.maxiter);
                %freqdom.ffrf2(T,R,[],Z,H,[],U,Omega, ...
                %Freq,opt.tolerance,opt.maxiter);
        end
        % Solution not available.
        if flag
            utils.warning('model:ffrf', ...
                'Solution not available %s.', ...
                preparser.alt2str(nanAlt));
        end
    end % doFfrf()


end
