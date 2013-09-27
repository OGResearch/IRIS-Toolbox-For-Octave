function x = grid2dat(x,freq,pos)
% dat2grid  Convert x-axis grid to dates.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if ~exist('pos','var')
    pos = 'c';
end

if length(freq) == 1 && length(x) > 1
    freq = freq*ones(size(x));
end

%**************************************************************************

% Index of normal frequencies.
normfreq = freq > 0;

if any(normfreq)
    switch pos
        case 's'
            % x(normfreq) = x(normfreq);
        case 'e'
            x(normfreq) = x(normfreq) - 1./freq(normfreq);
        otherwise
            x(normfreq) = x(normfreq) - 1./(2*freq(normfreq));
    end
    x(normfreq) = dec2dat(x(normfreq),freq(normfreq));
end

if any(~normfreq)
    negative = x < 0;
    x(~normfreq & negative) = floor(x(~normfreq & negative));
    x(~normfreq & ~negative) = ceil(x(~normfreq & ~negative));
end

end