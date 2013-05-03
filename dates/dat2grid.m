function x = dat2grid(x,pos)
% dat2grid  Convert dates to x-axis grid.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if nargin < 2
    pos = 'c';
end

%**************************************************************************

freq = datfreq(x);

% Index of normal frequencies.
normfreq = freq > 0;

if any(normfreq)
    switch pos(1)
        case 's'
            % Start of the period.
            x(normfreq) = dat2dec(x(normfreq));
        case 'e'
            % End of the period.
            x(normfreq) = dat2dec(x(normfreq)+1);
        otherwise
            % Centre of the period.
            x(normfreq) = dat2dec(x(normfreq));
            x(normfreq) = x(normfreq) + 1./(2*freq);
    end
end

end
