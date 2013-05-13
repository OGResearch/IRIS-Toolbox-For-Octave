function [x,t] = mybpass(x,start,band,opt,trendopt)
% MYBPASS  [Not a public function] General band-pass filter.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

% Low and high periodicities and frequencies.
lowPer = max(2,min(band));
highPer = max(band);
lowFreq = 2*pi/highPer;
highFreq = 2*pi/lowPer;

% Set the window constant for HWFSF.
if strcmpi(opt.method,'hwfsf')
    switch opt.window
        case 'hanning'
            a = 0.50;
        case 'hamming'
            a = 0.53;
        case 'none'
            a = 1;
    end
end

if opt.log
    x = log(x);
end

if opt.detrend
    [t,tt,ts,s] = tseries.mytrend(x,start,trendopt);
else
    t = zeros(size(x));
    tt = zeros(size(x));
    ts = zeros(size(x));
    s = [];
end

% Include time line in the output trend.
addtime = opt.detrend ...
    && opt.addtrend && isinf(highPer);

% Include seasonals in the output trend.
addseason = opt.detrend ...
    && opt.addtrend && ~isempty(s) ...
    && s >= lowPer && s <= highPer;

A = [];
nobs0 = 0;
for i = 1 : size(x,2)
    sample = getsample(x(:,i));
    nobs = sum(sample);
    if nobs == 0
        continue
    end
    
    % Remove time trend and seasonals, or mean.
    xi = x(sample,i);
    if opt.detrend
        ti = t(sample,i);
    else
        ti = mean(xi);
        tt(sample,i) = ti;
    end
    xi = xi - ti;
    
    if any(isnan(xi))
        x(:,i) = NaN;
        continue
    end
    
    if strcmpi(opt.method,'cf')
        % Christiano-Fitzgerald.
        cf();
    else
        % H-windowed frequency-selective filter.
        hwfsf();
    end
    
    nobs0 = nobs;
end

% Include time line in the output trend.
if addtime
    x = x + tt;
end

% Include seasonals in the output trend.
if addseason
    x = x + ts;
end

% De-logarithmise back.
if opt.log
    x = exp(x);
    t = exp(t);
end

% Nested functions.

%***********************************************************************
    function cf()
        % Christiano-Fitzgerald filter.
        if any(nobs ~= nobs0)
            % Re-calculate C-F projection matrix only if needed.
            A = tseries.mychristianofitzgerald( ...
                nobs,lowPer,highPer,double(opt.unitroot),0);
        end
        x(sample,i) = A*xi;
        x(~sample,i) = NaN;
    end
% cf().

%***********************************************************************
    function hwfsf()
        if nobs ~= nobs0
            freq = (2*pi*(0:nobs-1)/nobs).';
            H = (freq >= lowFreq & freq <= highFreq);
            % Impose symmetry.
            H(2:end) = H(2:end) | H(end:-1:2);
            W = toeplitz([a,(1-a)/2,zeros(1,nobs-2)]);
            W(1,end) = (1-a)/2;
            W(end,1) = (1-a)/2;
            A = W*H;
        end
        x(sample,i) = ifft(A.*fft(xi));
        x(~sample,i) = NaN;
    end
% hwfsf().

end