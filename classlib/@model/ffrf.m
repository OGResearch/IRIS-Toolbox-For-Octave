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
% * `'exclude='` [ char | cellstr | *empty* ] - Remove the effect of these
% measurement variables from the FFRF.
%
% * `'maxIter='` [ numeric | *500* ] - Maximum number of iteration when
% computing the steady-state Kalman filter.
%
% * `'output='` [ *'namedmat'* | numeric ] - Output matrix `F` will be
% either a namedmat object or a plain numeric array; if the option
% `'select='` is used, `'output='` is always `'namedmat'`.
%
% * `'select='` [ char | cellstr | *`Inf`* ] - Return the frequency response
% function for selected variables only; `Inf` means all variables.
%
% * `'tolerance='` [ numeric | *1e-7* ] - Convergence tolerance when
% computing the steady-state Kalman filter.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Parse input arguments.
pp = inputParser();
pp.addRequired('M',@ismodel);
pp.addRequired('Freq',@isnumeric);
pp.parse(This,Freq);

% Parse options.
opt = passvalopt('model.ffrf',varargin{:});

if ischar(opt.select)
    opt.select = regexp(opt.select,'\w+','match');
end

if ischar(opt.exclude)
    opt.exclude = regexp(opt.exclude,'\w+','match');
end

isSelect = iscellstr(opt.select);
isNamedmat = strcmpi(opt.output,'namedmat') || isSelect;

% TODO: Implement the `'exclude='` option through the `'select='` option.

%--------------------------------------------------------------------------

ny = length(This.solutionid{1});
nx = length(This.solutionid{2});
nAlt = size(This.Assign,3);

exclude = myselect(This,'y',opt.exclude);

Freq = Freq(:)';
nFreq = length(Freq);
F = nan(nx,ny,nFreq,nAlt);

if ny > 0
    [flag,nanAlt] = isnan(This,'solution');
    for iAlt = find(~nanAlt)
        [T,R,~,Z,H,~,U,Omega] = mysspace(This,iAlt,false);
        % Compute FFRF.
        F(:,~exclude,:,iAlt) = ...
            freqdom.ffrf3( ...
            T,R,[],Z,H,[],U,Omega, ...
            Freq,exclude,opt.tolerance,opt.maxiter);
    end
    % Solution not available.
    if flag
        utils.warning('model', ...
            '#Solution_not_available',preparser.alt2str(nanAlt));
    end
end

% List of variables in rows and columns of `F`.
List = This.solutionvector(1:2);

% Convert output matrix to namedmat object.
if isNamedmat
    F = namedmat(F,List{2},List{1});
end

% Select requested variables.
if isSelect
    F = select(F,opt.select);
end

end