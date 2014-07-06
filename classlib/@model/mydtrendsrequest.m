function varargout = mydtrendsrequest(This,Req,Range,G,Alt)
% mydtrendsrequest   [Not a public function] Request deterministic trends.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    Range; %#ok<VUNUS>
catch %#ok<CTCH>
    Range = [];
end

try
    Alt; %#ok<VUNUS>
catch %#ok<CTCH>
    Alt = Inf;
end

if isequal(Alt,Inf)
    Alt = 1 : size(This.Assign,3);
elseif islogical(Alt)
    Alt = find(Alt);
else
    Alt = transpose(Alt(:));
end
nAlt = numel(Alt);

%--------------------------------------------------------------------------

ny = sum(This.nametype == 1);

switch Req
    case 'sstate'
        eqtn = This.eqtnF(This.eqtntype == 3);
        dtLevel = zeros(ny,nAlt);
        dtGrowth = zeros(ny,nAlt);
        count = 0;
        vecFunc = @(x) x(:);
        for iAlt = Alt
            count = count + 1;
            x = This.Assign(1,:,min(iAlt,end));
            % Exogenous variables in dtrend equations.
            gReal = real(This.Assign(1,This.nametype == 5,min(iAlt,end)));
            gImag = imag(This.Assign(1,This.nametype == 5,min(iAlt,end)));
            g0 = gReal.';
            g1 = gReal.' + gImag.';
            % Evaluate dtrend equations at time 0.
            dtLevel(:,count) = vecFunc(cellfun(@(fcn) fcn(x,1,0,g0),eqtn));
            % Evaluate dtrend equations at time 1 and subtract time 0.
            dtGrowth(:,count) = ...
                vecFunc(cellfun(@(fcn) fcn(x,1,1,g1),eqtn)) ...
                - dtLevel(:,count);
        end
        varargout{1} = dtLevel;
        varargout{2} = dtGrowth;
    case 'range'
        nPer = numel(Range);
        eqtn = This.eqtnF(This.eqtntype == 3);
        timeTrend = dat2ttrend(Range,This);
        W = zeros(ny,nPer,nAlt);
        count = 0;
        if ~isempty(Range)
            for iAlt = Alt
                count = count + 1;
                x = This.Assign(1,:,min(iAlt,end));
                g = G(:,:,min(iAlt,end));
                for j = 1 : ny
                    W(j,:,count) = eqtn{j}(x,1,timeTrend,g);
                end
            end
        end
        varargout{1} = W;
end

end