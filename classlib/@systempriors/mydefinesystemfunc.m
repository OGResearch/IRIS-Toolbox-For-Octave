function This = mydefinesystemfunc(This)

s = struct();

% Shock response function.
s.srf.rowName = [This.yVec,This.xVec];
s.srf.colName = [This.eVec];
s.srf.defaultPageStr = '1';
s.srf.validatePage = @(x) isnumeric(x) && all(x >= 1) && all(isround(x));
s.srf.page = zeros(1,0);
s.srf.activeInput = false(1,length(s.srf.colName));

% Filter frequency response function.
s.ffrf.rowName = [This.xVec];
s.ffrf.colName = [This.yVec];
s.ffrf.defaultPageStr = 'NaN';
s.ffrf.validatePage = @isnumeric;
s.ffrf.page = zeros(1,0);
s.ffrf.activeInput = false(1,length(s.ffrf.colName));

% Covariance.
s.cov.rowName = [This.yVec,This.xVec];
s.cov.colName = [This.yVec,This.xVec];
s.cov.defaultPageStr = '0';
s.cov.validatePage = @(x) isnumeric(x) && all(x >= 0) && all(isround(x));
s.cov.page = zeros(1,0);
s.cov.activeInput = false(1,length(s.cov.colName));

% Correlation.
s.corr.rowName = [This.yVec,This.xVec];
s.corr.colName = [This.yVec,This.xVec];
s.corr.defaultPageStr = '0';
s.corr.validatePage = @(x) isnumeric(x) && all(x >= 0) && all(isround(x));
s.corr.page = zeros(1,0);
s.corr.activeInput = false(1,length(s.corr.colName));

% Power spectrum.
s.pws.rowName = [This.yVec,This.xVec];
s.pws.colName = [This.yVec,This.xVec];
s.pws.defaultPageStr = 'NaN';
s.pws.validatePage = @isnumeric;
s.pws.page = zeros(1,0);
s.pws.activeInput = false(1,length(s.pws.colName));

% Spectral density.
s.spd.rowName = [This.yVec,This.xVec];
s.spd.colName = [This.yVec,This.xVec];
s.spd.defaultPageStr = 'NaN';
s.spd.validatePage = @isnumeric;
s.spd.page = zeros(1,0);
s.spd.activeInput = false(1,length(s.spd.colName));

This.systemFunc = s;

end
