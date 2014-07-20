function [S,D,YXVec,Freq] = xsf(This,Freq,varargin)
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
% * `'matrixFmt='` [ *`'namedmat'`* | `'plain'` ] - Return matrices `S`
% and `D` as either [`namedmat`](namedmat/Contents) objects (i.e.
% matrices with named rows and columns) or plain numeric arrays.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar on in the
% command window.
%
% * `'select='` [ *`@all`* | char | cellstr ] - Return XSF for selected
% variables only; `@all` means all variables.
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

if isintscalar(Freq)
    nFreq = Freq;
    Freq = linspace(0,pi,nFreq);
else
    Freq = Freq(:).';
    nFreq = length(Freq);
end

isDensity = nargout > 1;
isSelect = ~isequal(opt.select,@all);
isNamedMat = isanystri(opt.MatrixFmt,{'namedmat'});

%--------------------------------------------------------------------------

ny = length(This.solutionid{1});
nx = length(This.solutionid{2});
nAlt = size(This.Assign,3);

% Pre-process filter options.
YXVec = myvector(This,'yx');
[~,filter,~,applyTo] = freqdom.applyfilteropt(opt,Freq,YXVec);

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

% Convert power spectrum to spectral density.
if isDensity
    C = acf(This);
    D = freqdom.psf2sdf(S,C);
end

% Select variables if requested.
if isSelect
    [S,pos] = namedmat.myselect(S,YXVec,YXVec,opt.select,opt.select);
    pos = pos{1};
    YXVec = YXVec(pos);
    if isDensity
        D = D(pos,pos,:,:,:);
    end
end

if false % ##### MOSW
    % Convert double arrays to namedmat objects if requested.
    if isNamedMat
        S = namedmat(S,YXVec,YXVec);
        try %#ok<TRYNC>
            D = namedmat(D,YXVec,YXVec);
        end
    end
else
    % Do nothing.
end

end
