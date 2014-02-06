function [S,D] = xsf(This,Freq,varargin)
% xsf  Power spectrum and spectral density functions for VAR variables.
%
% Syntax
% =======
%
%     [S,D] = xsf(V,Freq,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% * `Freq` [ numeric ] - Vector of Frequencies at which the XSFs will be
% evaluated.
%
% Output arguments
% =================
%
% * `S` [ numeric ] - Power spectrum matrices.
%
% * `D` [ numeric ] - Spectral density matrices.
%
% Options
% ========
%
% * `'applyTo='` [ cellstr | char | *`':'`* ] - List of variables to which
% the `'filter='` will be applied; `':'` means all variables.
%
% * `'filter='` [ char  | *empty* ] - Linear filter that is applied to
% variables specified by 'applyto'.
%
% * `'nFreq='` [ numeric | *256* ] - Number of equally spaced frequencies
% over which the 'filter' is numerically integrated.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the command
% window.
%
% Description
% ============
%
% The output matrices, `S` and `D`, are `N`-by-`N`-by-`K`, where `N` is the
% number of VAR variables and `K` is the number of frequencies (i.e. the
% length of the vector `freq`).
%
% The k-th page is the `S` matrix, i.e. `S(:,:,k)`, is the cross-spectrum
% matrix for the VAR variables at the k-th frequency. Similarly, the `k`-th
% page in `D`, i.e. `D(:,:,k)`, is the cross-density matrix.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Parse input arguments.
pp = inputParser();
if ismatlab
pp.addRequired('VAR',@(x) isa(x,'VAR'));
pp.addRequired('freq',@isnumeric);
pp.parse(This,Freq);
else
pp = pp.addRequired('VAR',@(x) isa(x,'VAR'));
pp = pp.addRequired('freq',@isnumeric);
pp = pp.parse(This,Freq);
end

opt = passvalopt('VAR.xsf',varargin{:});

%--------------------------------------------------------------------------

ny = size(This.A,1);
nAlt = size(This.A,3);
Freq = Freq(:)';
nFreq = length(Freq);

% Pre-process filter options.
[~,filter,~,applyTo] = freqdom.applyfilteropt(opt,Freq,This.Ynames);

if opt.progress
    progress = progressbar('IRIS VAR.xsf progress');
end

S = nan(ny,ny,nFreq,nAlt);
for iAlt = 1 : nAlt
    % Compute power spectrum function.
    S(:,:,:,iAlt) = freqdom.xsfvar( ...
        This.A(:,:,iAlt),This.Omega(:,:,iAlt),Freq,filter,applyTo);
    if opt.progress
        update(progress,iAlt/nAlt);
    end
end
S = S / (2*pi);

if nargout > 1
    % Convert power spectrum to spectral density.
    D = freqdom.psf2sdf(S,acf(This));
end

end