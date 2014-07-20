function [StdcorrReal,StdcorrImag] ...
    = mytune2stdcorr(This,Range,J,Opt,varargin)
% mytune2stdcorr  [Not a public function] Convert the option 'vary=' or a tune database to stdcorr vector.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

isClip = any(strcmpi(varargin,'clip'));
isImag = nargout > 1;

%--------------------------------------------------------------------------

% We do not include pre-sample.

ne = sum(This.nametype == 3);
nStdcorr = ne+ne*(ne-1)/2;

if isempty(Range)
    StdcorrReal = nan(nStdcorr,0);
    StdcorrImag = nan(nStdcorr,0);
    return
end

d = [];
doTimeVarying();

Range = Range(1) : Range(end);
nPer = length(Range);
StdcorrReal = nan(nStdcorr,nPer);

if ~isempty(d)
    c = fieldnames(d);
    [ans,stdcorrpos] = mynameposition(This,c); %#ok<NOANS,ASGLU>
    for i = find(~isnan(stdcorrpos))
        x = d.(c{i});
        if isa(x,'tseries')
            x = rangedata(x,Range);
            x = x(:,1);
            x = x(:).';
        end
        StdcorrReal(stdcorrpos(i),:) = x;
    end
end

if isImag
    StdcorrImag = imag(StdcorrReal);
end
StdcorrReal = real(StdcorrReal);

% Vector of non-NaN variances/stdevs.
scRealInx = ~isnan(StdcorrReal);

if isImag
    scImagInx = ~isnan(StdcorrImag);
end

% If requested, remove all periods behind the last user-supplied data
% point.
if isClip
    last = find(any(scRealInx,1),1,'last');
    StdcorrReal = StdcorrReal(:,1:last);
    if isImag
        last = find(any(scImagInx,1),1,'last');
        StdcorrImag = StdcorrImag(:,1:last);
    end
end

% Nested functions.

%**************************************************************************
    function doTimeVarying()
        if isfield(Opt,'vary') && ~isempty(Opt.vary)
            d = Opt.vary;
        end
        if ~isempty(J)
            if isempty(d)
                d = J;
            else
                utils.error('model', ...
                    ['Cannot combine a tune database and ', ...
                    'the option ''vary=''.']);
            end
        end
    end % doTimeVarying().

end