function [S,D,List,Freq] = xsf(This,Freq,varargin)
% xsf  Power spectrum and spectral density of model variables.
%
% Syntax
% =======
%
%     [S,D,List] = xsf(M,Freq,...)
%     [S,D,List,Freq] = xsf(M,NFreq,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% * `Freq` [ numeric ] - Vector of frequencies at which the XSFs will be
% evaluated.
%
% * `NFreq` [ numeric ] - Total number of requested frequencies; the
% frequencies will be evenly spread between 0 and `pi`.
%
% Output arguments
% =================
%
% * `S` [ namedmat | numeric ] - Power spectrum matrices.
%
% * `D` [ namedmat | numeric ] - Spectral density matrices.
%
% * `List` [ cellstr ] - List of variable in order of appearance in rows
% and columns of `S` and `D`.
%
% * `Freq` [ numeric ] - Vector of frequencies at which the XSFs has been
% evaluated.
%
% Options
% ========
%
% * `'applyTo='` [ cellstr | char | *`Inf`* ] - List of variables to which
% the option `'filter='` will be applied; `Inf` means all variables.
%
% * `'filter='` [ char  | *empty* ] - Linear filter that is applied to
% variables specified by 'applyto'.
%
% * `'nFreq='` [ numeric | *`256`* ] - Number of equally spaced frequencies
% over which the 'filter' is numerically integrated.
%
% * `'output='` [ *`'namedmat'`* | `'numeric'` ] - Output matrices `S` and
% `F` will be either namedmat objects or plain numeric arrays; if the
% option `'select='` is used, `'output='` is always a namedmat object.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar on in the
% command window.
%
% * `'select='` [ cellstr | *`Inf`* ] - Return XSF for selected variables
% only; `Inf` means all variables.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

opt = passvalopt('model.xsf',varargin{:});

if is.numericscalar(Freq) && Freq == round(Freq)
    nFreq = Freq;
    Freq = linspace(0,pi,nFreq);
else
    Freq = Freq(:).';
    nFreq = length(Freq);
end

if ischar(opt.select)
    opt.select = regexp(opt.select,'\w+','match');
end

isSelect = iscellstr(opt.select);
isNamedmat = strcmpi(opt.output,'namedmat') || isSelect;
isDensity = nargout > 1;

%--------------------------------------------------------------------------

ny = length(This.solutionid{1});
nx = length(This.solutionid{2});
nAlt = size(This.Assign,3);

% Pre-process filter options.
sspaceVec = [This.solutionvector{1:2}];
[~,filter,~,applyTo] = freqdom.applyfilteropt(opt,Freq,sspaceVec);

if opt.progress
    progress = progressbar('IRIS VAR.xsf progress');
end

S = nan(ny+nx,ny+nx,nFreq,nAlt);
isSol = true(1,nAlt);
for iAlt = 1 : nAlt
    [T,R,~,Z,H,~,U,Omega] = mysspace(This,iAlt,false);
    
    % Continue immediately if solution is not available.
    isSol(iAlt) = all(~isnan(T(:)));
    if ~isSol(iAlt)
        continue
    end
    
    nUnit = mynunit(This,iAlt);
    S(:,:,:,iAlt) = freqdom.xsf(T,R,[],Z,H,[],U,Omega,nUnit, ...
        Freq,filter,applyTo);
    if opt.progress
        update(progress,iAlt/nAlt);
    end
end
S = S / (2*pi);

% Report NaN solutions.
if ~all(isSol)
    utils.warning('model', ...
        'Solution(s) not available %s.', ...
        preparser.alt2str(~isSol));
end

% List of variables in rows and columns of `S` and `D`.
List = [This.solutionvector{1:2}];

% Convert power spectrum to spectral density.
if isDensity
    C = acf(This);
    D = freqdom.psf2sdf(S,C);
end

% Convert output matrices to namedmat objects.
if isNamedmat
    S = namedmat(S,List,List);
    if isDensity
        D = namedmat(D,List,List);
    end
end

% Select variables. For backward compatibility only.
% Use SELECT function afterwards instead.
if isSelect
    [S,inx] = select(S,opt.select);
    if isDensity
        D = D(inx{1},inx{2},:,:);
    end
end

end