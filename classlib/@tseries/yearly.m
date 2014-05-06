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
        utils.warning('tseries:yearly', ...
            'The function yearly() is not implemented for weekly series yet.');
    otherwise
        % Call `disp` with yearly disp2d implementation.
        disp(This,'',@xxDisp2dYearly);
end

end


% Subfunctions...


%**************************************************************************
function X = xxDisp2dYearly(Start,Data,Tab,Sep,Num2StrFunc)
% `Data` is always 2D at most.
[nPer,nx] = size(Data);
[~,p,freq] = dat2ypf(Start);

% If the input tseries does not start in the first period of the year, padd
% `Data` with NaN's at the beginning.
if p > 1
    nPre = p - 1;
    Data = [nan(nPre,nx);Data];
    nPer = size(Data,1);
end

% If the input tseries does not end in the last period of the year, padd
% `Data` with NaN's at the end.
nYear = nPer / freq;
if nYear < ceil(nYear)
    nPost = freq*ceil(nYear) - nPer;
    Data = [Data;nan(nPost,nx)];
    nYear = ceil(nYear);
end

% Reshape `Data` to get one year per row.
Data = reshape(Data,freq,nYear,nx);
Data = permute(Data,[3,1,2]);

dataTable = [];
dates = {};
for i = 1 : nYear
    lineStart = Start + (i-1)*freq;
    lineEnd = lineStart + freq-1;
    dates{end+1} = [ ...
        strjust(dat2char(lineStart)),'-', ...
        strjust(dat2char(lineEnd)), ...
        Sep, ...
        ]; %#ok<AGROW>
    if nx > 1
        dates{end+(1:nx-1)} = ''; %#ok<AGROW>
    end
    dataTable = [dataTable;Data(:,:,i)]; %#ok<AGROW>
end

dates = char(dates);
dataChar = Num2StrFunc(dataTable);
repeat = ones(size(dates,1),1);
X = [Tab(repeat,:),dates,dataChar];

end % xxDisp2dYearly()
