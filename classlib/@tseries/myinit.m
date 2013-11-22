function This = myinit(This,Dates,Data)
% myinit  [Not a public function] Create start date and data for new tseries object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isa(Data,'single')
    prec = 'single';
else
    prec = 'double';
end

Dates = Dates(:);
nPer = length(Dates);
nObs = size(Data,1);
dataSize = size(Data);
if nObs == 0 && (all(isnan(Dates)) || nPer == 0)
    dataSize(1) = 0;
    This.start = NaN;
    This.data = zeros(dataSize,prec);
    return
end

if dataSize(1) ~= nPer
    utils.error('tseries', ...
        'Number of dates and number of rows of data must match.');
end

Data = Data(:,:);

% Remove NaN dates.
nanDates = isnan(Dates);
if any(nanDates)
    Data(nanDates,:) = [];
    Dates(nanDates) = [];
end

% No proper date entered, return an empty tseries object.
if isempty(Dates)
    This.data = zeros([0,dataSize(2:end)]);
    This.start = NaN;
    return
end

% Start date is the minimum date found.
start = min(Dates);

% The actual stretch of the tseries range.
nPer = round(max(Dates) - start + 1);
if isempty(nPer)
    nPer = 0;
end
dataSize(1) = nPer;

% Assign data points at proper dates only.
This.data = nan(dataSize,prec);
pos = round(Dates - start + 1);

% Assign user data to tseries object; note that higher dimensions will be
% preserved in `this.data`.
This.data(pos,:) = Data;
This.start = start;

end