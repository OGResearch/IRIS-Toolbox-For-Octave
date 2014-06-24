function D = rollback(This,D,Range,Last)
% rollback  Prepare database for a rollback run of Kalman filter.
%
% Syntax
% =======
%
%     Inp = rollback(M,Inp,Range,Date)
%
% Input argument
% ===============
%
% * `M` [ model ] - Model object with a single parameterization.
%
% * `Inp` [ struct ] - Database with a single set of input data for a
% Kalman filter.
%
% * `Range` [ numeric ] - Filter data range.
%
% * `Date` [ numeric ] - Date up to which the input data entries will be
% rolled back, see Description.
%
% Output argument
% ================
%
% * `Inp` [ struct ] - New database with new data sets added to each
% tseries for measurement variables, taking out one observation at a time,
% see Description.
%
% Description
% ============
%
% The function `rollback` takes a database with a single set of input data
% that is supposed to be used in a future call to a Kalman filter,
% [`model/filter`](model/filter), and creates additional data sets (i.e.
% addition columns in tseries for measurement variables contained in the
% database) in the following way:
%
% * the total number of the new data sets (new columns added to each
% measurement tseries) is N = NPer*Ny where NPer is the number of rollback
% periods, from `Date` to the end of `Range` (including both), and Ny is
% the number of measurement variables in the model `M`.
%
% * The first additional data set is created by removing the observation on
% the last measurement variable in the last period (i.e. end of `Range`)
% and replacing it with a `NaN`.
%
% * The second additional data set is created by removing the observatoins
% on the last two measurement variables in the last period, and so on.
%
% * The N-th (last) additional data set is created by removing all
% observations in all periods between `Data` and end of `Range`.
%
% Example
% ========
%
% If the model `m` contains, for instance, 3 measurement variable, the
% following commands will produce a total of 13 Kalman filter runs, the
% first one on the original database d, and the other 12 on the rollback
% data sets, with individual observations removed one by one:
%
%     dd = rollback(m,d,qq(2000,1):qq(2015,4),qq(2015,1));
%     [mf,f] = filter(m,dd,qq(2000,1):qq(2015,4));
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('M',@(x) is.model(x) && length(x) == 1);
pp.addRequired('Inp',@(x) isstruct(x) || isempty(x));
pp.addRequired('Range',@(x) isnumeric(x) && all(freqcmp(x)));
pp.addRequired('Back',@(x) is.numericscalar(x) && all(freqcmp(x,Range)));
pp.parse(This,D,Range,Last);


%--------------------------------------------------------------------------

yList = This.name(This.nametype == 1);
ny = length(yList);

Range = Range(1) : Range(end);
if floor(Last) > floor(Range(end))
    Last = Range(end);
elseif floor(Last) < floor(Range(1))
    Last = Range(1);
end

rbRange = datrange(Range(end),Last,-1);
if isempty(rbRange)
    return
end
nPer = length(Range);
nRbPer = length(rbRange);

ixTseries = false(1,ny);
ixSingleCol = false(1,ny);
addData = nan(ny,nPer);
doChkInpData();
nAdd = nRbPer * ny;
addData = repmat(addData,1,1,nAdd);

page = 0;
for t = nPer : -1 : 1
    for i = ny : -1 : 1
        page = page + 1;
        addData(i,t,page:end) = NaN;
    end
end

for i = find(ixTseries & ixSingleCol)
    name = yList{i};
    iData = addData(i,:,:);
    iData = permute(iData,[2,3,1]);
    D.(name)(Range,1+(1:nAdd)) = iData;
end


% Nested functions...


%**************************************************************************
    function doChkInpData()
        for ii = 1 : ny
            name = yList{ii};
            if isfield(D,name)
                x = D.(name);
                ixTseries(ii) = is.tseries(x);
                if ixTseries(ii)
                    ixSingleCol(ii) = size(x.data(:,:),2) == 1;
                end
            end
            if ixTseries(ii) && ixSingleCol(ii)
                addData(ii,:) = rangedata(x,Range).';
            else
                addData(ii,:) = nan(1,nPer);
            end
        end
        ixInvalid = ixTseries & ~ixSingleCol;
        if any(ixInvalid)
            utils.error('model:rollback', ...
                'This times series includes multiple data sets: ''%s''.', ...
                yList{ixInvalid});
        end
    end % doChkInpData()


end