function yearly(This)
% yearly  Display tseries object one full year per row.
%
% Syntax
% =======
%
%     yearly(X)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object that will be displayed one full year
% of observations per row.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

freq = datfreq(This.start);

switch freq
    case 0
        daily(This);
    case 1
        disp(This);
    case 52
        disp(This);
    otherwise
        % Include pre-sample and post-sample periods to complete full years.
        freq = datfreq(This.start);
        startYear = dat2ypf(This.start);
        nPer = size(This.data,1);
        endYear = dat2ypf(This.start+nPer-1);
        This.start = datcode(freq,startYear,1);
        This.data = rangedata(This,[This.start,datcode(freq,endYear,freq)]);
        % Call `disp` with yearly disp2d implementation.
        disp(This,'',@xxDisp2dYearly);
end

end


% Subfunctions...


%**************************************************************************
function X = xxDisp2dYearly(Start,Data,Tab,Sep,Num2StrFunc)
[nPer,nX] = size(Data);
freq = datfreq(Start);
nYear = nPer / freq;
Data = reshape(Data,[freq,nYear,nX]);
Data = permute(Data,[3,1,2]);
tmpData = Data;
Data = [];
dates = {};
for i = 1 : nYear
    lineStart = Start + (i-1)*freq;
    lineEnd = lineStart + freq-1;
    dates{end+1} = [ ...
        strjust(dat2char(lineStart)),'-', ...
        strjust(dat2char(lineEnd)), ...
        Sep, ...
        ]; %#ok<AGROW>
    if nX > 1
        dates{end+(1:nX-1)} = ''; %#ok<AGROW>
    end
    Data = [Data;tmpData(:,:,i)]; %#ok<AGROW>
end
dates = char(dates);
dataChar = Num2StrFunc(Data);
repeat = ones(size(dates,1),1);
X = [Tab(repeat,:),dates,dataChar];
end % xxDisp2dYearly().