classdef (InferiorClasses={?matlab.graphics.axis.Axes}) ...
        tseries < getsetobj & userdataobj 
    
    % tseries  Time series objects and functions.
    %
    % Tseries methods:
    %
    % Constructor
    % ============
    %
    % * [`tseries`](tseries/tseries) - Create new time series (tseries) object.
    %
    % Getting information about tseries objects
    % ==========================================
    %
    % * [`daily`](tseries/daily) - Calendar view of a daily tseries object.
    % * [`enddate`](tseries/enddate) - Date of the last available observation in a tseries object.
    % * [`freq`](tseries/freq) - Frequency of a tseries object.
    % * [`get`](tseries/get) - Query tseries object property.
    % * [`isequal`](tseries/isequal) - [Not a public function] Compare two tseries objects.
    % * [`length`](tseries/length) - Length of tseries object.
    % * [`ndims`](tseries/ndims) - Number of dimensions in tseries object data.
    % * [`size`](tseries/size) - Size of tseries object data.
    % * [`startdate`](tseries/startdate) - Date of the first available observation in a tseries object.
    % * [`yearly`](tseries/yearly) - Display tseries object one full year per row.
    %
    % Referencing tseries objects
    % ============================
    %
    % * [`subsasgn`](tseries/subsasgn) - Subscripted assignment for tseries objects.
    % * [`subsref`](tseries/subsref) - Subscripted reference function for tseries objects.
    %
    % Maths and statistics functions and operators
    % =============================================
    %
    % Some of the following functions require the Statistics Toolbox.
    %
    % `+`, `-`, `*`, `\`, `/`, `^`, `&`, `|`, `~`, `==`, `~=`, `>=`, `>`, `<`,
    % `<=`, `abs`, `acos`, `asin`, `atan`, `atan2`, `ceil`, `cos`,  `exp`,
    % `fix`, `floor`,`imag`, `isinf`, `isnan`, `log`, `log10`, `real`, `round`,
    % `sin`, `sqrt`, `tan`, `normpdf`, `normcdf`, `prctile`, `lognpdf`,
    % `logncdf`
    %
    % The behaviour of the following functions depend on the dimension along
    % which they are performed.
    %
    % Some of the following functions require the Statistics Toolbox.
    %
    % `all`, `any`, `cumprod`, `cumsum`, `find`, `geomean`, `max`, `mean`,
    % `median`, `min`, `mode`, `nanmean`, `nanstd`, `nansum`, `nanvar`, `prod`,
    % `std`, `sum`, `var`
    %
    % Filters
    % ========
    %
    % * [`arf`](tseries/arf) - Run autoregressive function on a tseries object.
    % * [`bpass`](tseries/bpass) - Band-pass filter.
    % * [`bwf`](tseries/bwf) - Butterworth filter with tunes.
    % * [`bwf2`](tseries/bwf2) - Swap output arguments of the Butterworth filter with tunes.
    % * [`detrend`](tseries/detrend) - Remove a linear time trend.
    % * [`expsmooth`](tseries/expsmooth) - Exponential smoothing.
    % * [`hpf`](tseries/hpf) - Hodrick-Prescott filter with tunes (aka LRX filter).
    % * [`hpf2`](tseries/hpf2) - Swap output arguments of the Hodrick-Prescott filter with tunes.
    % * [`fft`](tseries/fft) - Discrete Fourier transform of tseries object.
    % * [`llf`](tseries/llf) - Local level filter (aka random walk plus white noise) with tunes.
    % * [`llf2`](tseries/llf2) - Swap output arguments of the local linear trend filter with tunes.
    % * [`moving`](tseries/moving) - Apply function to moving window of observations.
    % * [`trend`](tseries/trend) - Estimate a time trend.
    % * [`x12`](tseries/x12) - Access to X13-ARIMA-SEATS seasonal adjustment program.
    %
    % Estimation and sample characteristics
    % ======================================
    %
    % Note that most of the sample characteristics are listed above in the
    % Maths and statistics functions and operators section.
    %
    % * [`acf`](tseries/acf) - Sample autocovariance and autocorrelation functions.
    % * [`hpdi`](tseries/hpdi) - Highest probability density interval.
    % * [`chowlin`](tseries/chowlin) - Chow-Lin distribution of low-frequency observations over higher-frequency periods.
    % * [`regress`](tseries/regress) - Ordinary or weighted least-square regression.
    %
    % Visualising tseries objects
    % ============================
    %
    % * [`area`](tseries/area) - Area graph for tseries objects.
    % * [`bar`](tseries/bar) - Bar graph for tseries objects.
    % * [`barcon`](tseries/barcon) - Contribution bar graph for tseries objects.
    % * [`errorbar`](tseries/errorbar) - Line plot with error bars.
    % * [`plot`](tseries/plot) - Line graph for tseries objects.
    % * [`plotcmp`](tseries/plotcmp) - Comparison graph for two time series.
    % * [`plotpred`](tseries/plotpred) - Plot Kalman filter predictions.
    % * [`plotyy`](tseries/plotyy) - Line plot function with LHS and RHS axes for time series.
    % * [`scatter`](tseries/scatter) - Scatter graph for tseries objects.
    % * [`spy`](tseries/spy) - Visualise tseries observations that pass a test.
    % * [`stem`](tseries/stem) - Plot tseries as discrete sequence data.
    %
    % Manipulating tseries objects
    % =============================
    %
    % * [`empty`](tseries/empty) - Empty tseries object preserving its size in 2nd and higher dimensions.
    % * [`permute`](tseries/permute) - Permute dimensions of a tseries object.
    % * [`redate`](tseries/redate) - Change time dimension of a tseries object.
    % * [`reshape`](tseries/reshape) - Reshape size of time series in 2nd and higher dimensions.
    % * [`resize`](tseries/resize) - Clip tseries object down to a specified date range.
    % * [`sort`](tseries/sort) - Sort tseries columns by specified criterion.
    %
    % Converting tseries objects
    % ===========================
    %
    % * [`convert`](tseries/convert) - Convert tseries object to a different frequency.
    % * [`double`](tseries/double) - Return tseries observations as double-precision numeric array.
    % * [`doubledata`](tseries/doubledata) - Convert tseries observations to double precision.
    % * [`single`](tseries/single) - Return tseries observations as single-precision numeric array.
    % * [`singledata`](tseries/singledata) - Convert tseries observations to single precision.
    %
    % Other tseries functions
    % ========================
    %
    % * [`apct`](tseries/apct) - Annualised percent rate of change.
    % * [`bsxfun`](tseries/bsxfun) - Standard BSXFUN implemented for tseries objects.
    % * [`cumsumk`](tseries/cumsumk) - Cumulative sum with a k-period leap.
    % * [`destdise`](tseries/destdise) - Destandardise tseries object by applying specified standard deviation and mean to it.
    % * [`diff`](tseries/diff) - First difference.
    % * [`interp`](tseries/interp) - Interpolate missing observations.
    % * [`normalise`](tseries/normalise) - Normalise (or rebase) data to particular date.
    % * [`pct`](tseries/pct) - Percent rate of change.
    % * [`round`](tseries/round) - Round tseries data to specified number of decimals.
    % * [`rmse`](tseries/rmse) - Compute RMSE for given observations and predictions.
    % * [`stdise`](tseries/stdise) - Standardise tseries data by subtracting mean and dividing by std deviation.
    % * [`windex`](tseries/windex) - Simple weighted or Divisia index.
    % * [`wmean`](tseries/wmean) - Weighted average of time series observations.
    %
    % Getting on-line help on tseries functions
    % ==========================================
    %
    %     help tseries
    %     help tseries/function_name
    %
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2014 IRIS Solutions Team.
    
    properties
        start = NaN;
        data = zeros(0,1);
    end
    
    methods
        function This = tseries(varargin)
            % tseries  Create new time series (tseries) object.
            %
            % Syntax
            % =======
            %
            %     X = tseries()
            %     X = tseries(Dates,Values)
            %     X = tseries(Dates,Values,Comment)
            %
            % Input arguments
            % ================
            %
            % * `Dates` [ numeric ] - Dates for which observations will be supplied;
            % `dates` do not have to be sorted in ascending order. If `dates` is scalar
            % and `values` have multiple rows, then the date in `dates` is interpreted
            % as a startdate for the time series.
            %
            % * `Values` [ numeric | function_handle ] - Numerical values
            % (observations) arranged columnwise, or a function that will be used to
            % create an N-by-1 array of values, where N is the number of `dates`.
            %
            % * `Comment` [ char | cellstr ] - Comment or comments attached to each
            % column of observations.
            %
            % Output arguments
            % =================
            %
            % * `X` [ tseries ] - New tseries object.
            %
            % Description
            % ============
            %
            % Example
            % ========
            
            % -IRIS Toolbox.
            % -Copyright (c) 2007-2014 IRIS Solutions Team.
            
            This = This@userdataobj();
            This.Comment = {''};
            
            % Empty call.
            if nargin == 0
                return
            end
            % Tseries input.
            if nargin == 1 && is.tseries(varargin{1})
                This = varargin{1};
                return
            end
            % Struct input. Called from within load(), loadobj(), loadstruct(), cat(),
            % hdataouput().
            if nargin == 1 && isstruct(varargin{1})
                if isfield(varargin{1},'start') ...
                        && isfield(varargin{1},'data') ...
                        && isfield(varargin{1},'Comment') ...
                        && isfield(varargin{1},'UserData')
                    This.start = varargin{1}.start;
                    This.data = varargin{1}.data;
                    This.Comment = varargin{1}.Comment;
                    This.UserData = varargin{1}.UserData;
                else
                    This = mystruct2obj(This,varargin{1});
                end
                return
            end
            
            % User dates.
            usrDates = varargin{1}(:);
            nPer = length(usrDates);
            
            % User data.
            if nargin < 2
                usrData = nan(size(usrDates,1),1);
            else
                usrData = varargin{2};
            end
            
            % User comments.
            if nargin < 3
                usrComment = '';
            else
                usrComment = varargin{3};
            end
            
            % Parse required input arguments.
            pp = inputParser();
            pp.addRequired('Dates',@isnumeric);
            pp.addRequired('Data',@(x) ...
                isnumeric(x) || islogical(x) || ischar(x) || is.func(x));
            pp.addRequired('Comment',@(x) ischar(x) || iscellstr(x));
            pp.parse(usrDates,usrData,usrComment);
            
            %--------------------------------------------------------------
            
            % Find out the date frequency and check for its consistency.
            freq = datfreq(usrDates);
            freq(isnan(freq)) = [];
            if length(freq) > 1 && any(freq(1) ~= freq(2:end))
                error('All dates must have the same frequency.');
            end
            
            % Create data from a function handle or function name.
            if ischar(usrData) && strcmpi(usrData,'lintrend')
                usrData = (1 : nPer).';
            elseif ischar(usrData) || is.func(usrData)
                try
                    usrData = feval(usrData,[nPer,1]);
                catch %#ok<CTCH>
                    usrData = feval(char(usrData),[nPer,1]);
                end
            elseif isnumeric(usrData) || islogical(usrData)
                if sum(size(usrData) > 1) == 1 ...
                        && length(usrData) > 1 ...
                        && nPer > 1
                    % Squeeze if scalar time series is entered as an
                    % other-than-columnwise vectors.
                    usrData = usrData(:);
                elseif length(usrData) == 1 && nPer > 1
                    % Expand scalar `usrdata` point to match more than one of
                    % `usrdates`.
                    usrData = usrData(ones(size(usrDates)));
                end
            end
            
            % If `usrdates` is scalar and `usrdata` have multiple rows,
            % treat the `usrdates` as a start date and expand it accordingly.
            if nPer == 1 && size(usrData,1) > 1
                usrDates = usrDates + (0 : size(usrData,1)-1);
            end
            
            % Initialise the time series start date, data.
            This = myinit(This,usrDates,usrData);
            
            % Populate comments for each column.
            commentSize = size(This.data);
            commentSize(1) = 1;
            This.Comment = cell(commentSize);
            This.Comment(:) = {''};
            if isempty(usrComment)
                This.Comment(:) = {''};
            elseif ischar(usrComment)
                This.Comment(:) = {usrComment};
            elseif iscellstr(usrComment)
                try
                    This.Comment(:) = usrComment(:);
                catch Error
                    utils.error('model', ...
                        ['Cannot assign comments to the new tseries object. ', ...
                        'Check the size of the comments passed in.\n', ...
                        '\tMatlab says: %s'], ...
                        Error.message);
                end
            end
            
            if ~isempty(This.data) && any(any(isnan(This.data([1,end],:))))
                This = mytrim(This);
            end
            
        end
        
    end
    
    methods
        varargout = acf(varargin)
        varargout = apct(varargin)
        varargout = area(varargin)
        varargout = arf(varargin)
        varargout = bar(varargin)
        varargout = barcon(varargin)
        varargout = bpass(varargin)
        varargout = bwf(varargin)
        varargout = bwf2(varargin)
        varargout = bsxfun(varargin)
        varargout = chowlin(varargin)
        varargout = comment(varargin)
        varargout = conbar(varargin)
        varargout = convert(varargin)
        varargout = cumsumk(varargin)
        varargout = daily(varargin)
        varargout = destdise(varargin)
        varargout = detrend(varargin)
        varargout = diff(varargin)
        varargout = double(varargin)
        varargout = doubledata(varargin)
        varargout = empty(varargin)
        varargout = enddate(varargin)
        varargout = errorbar(varargin)
        varargout = expsmooth(varargin)
        varargout = fft(varargin)
        varargout = find(varargin)
        varargout = freq(varargin)
        varargout = get(varargin);
        varargout = horzcat(varargin)
        varargout = hpdi(varargin)
        varargout = hpf(varargin)
        varargout = hpf2(varargin)
        varargout = interp(varargin)
        varargout = isempty(varargin)
        varargout = isequal(varargin)
        varargout = isscalar(varargin)
        varargout = length(varargin)
        varargout = llf(varargin)
        varargout = llf2(varargin)
        varargout = moving(varargin)
        varargout = ndims(varargin)
        varargout = normalise(varargin)
        varargout = pct(varargin)
        varargout = permute(varargin)
        varargout = plot(varargin)
        varargout = plotcmp(varargin)
        varargout = plotyy(varargin)
        varargout = plotpred(varargin)
        varargout = range(varargin)
        varargout = regress(varargin)
        varargout = reshape(varargin)
        varargout = resize(varargin)
        varargout = rmse(varargin)
        varargout = round(varargin)
        varargout = scatter(varargin)
        varargout = single(varargin)
        varargout = singledata(varargin)
        varargout = size(varargin)
        varargout = sort(varargin)
        varargout = spy(varargin)
        varargout = startdate(varargin)
        varargout = stdise(varargin)
        varargout = stem(varargin)
        varargout = subsasgn(varargin)
        varargout = subsref(varargin)
        varargout = trend(varargin)
        varargout = vertcat(varargin)
        varargout = wmean(varargin)
        varargout = x12(varargin)
        varargout = yearly(varargin)
    end
    
    methods (Hidden)
        disp(varargin)
        varargout = mytrim(varargin)
        varargout = cat(varargin)
        varargout = cut(varargin)
        varargout = destdize(varargin)
        varargout = df(varargin)
        varargout = divisia(varargin)
        varargout = specrange(varargin)
        varargout = loadobj(varargin)
        varargout = maxabs(varargin)
        varargout = normalize(varargin)
        varargout = rangedata(varargin)
        varargout = replace(varargin)
        varargout = saveobj(varargin)
        varargout = specget(varargin)
        varargout = stdize(varargin)
    end
    
    methods (Access=protected,Hidden)
        mydispheader(varargin)
        varargout = myfilter(varargin)
        varargout = mygetdata(varargin)
        varargout = myinit(varargin)
        varargout = mylagorlead(varargin)
        varargout = mystruct2obj(varargin)
        varargout = binop(varargin)
        varargout = unop(varargin)
        varargout = catcheck(varargin)
        function dispcomment(varargin)
        end
    end
    
    methods (Static,Hidden)
        varargout = mybarcon(varargin)
        varargout = mybpass(varargin)
        varargout = mychristianofitzgerald(varargin)
        varargout = mycumsumk(varargin)
        varargout = mydestdize(varargin)
        varargout = mydiff(varargin)
        varargout = myexpsmooth(varargin)
        varargout = myhpdi(varargin)
        varargout = myjusterrorbars(varargin)
        varargout = mymoving(varargin)
        varargout = mynanmean(varargin)
        varargout = mynanstd(varargin)
        varargout = mynansum(varargin)
        varargout = mynanvar(varargin)
        varargout = myprctile(varargin)
        varargout = mypct(varargin)
        varargout = myplot(varargin)
        varargout = myshift(varargin)
        varargout = mystdize(varargin)
        varargout = mytrend(varargin)
    end
    
    methods (Static)
        varargout = edit(varargin)
    end
    
    methods (Hidden)
        function x = abs(x)
            x.data = abs(x.data);
        end
        function x = acos(x)
            x.data = acos(x.data);
            x = mytrim(x);
        end
        function x = and(x,y)
            x = binop(@and,x,y);
        end
        function x = asin(x)
            x.data = asin(x.data);
            x = mytrim(x);
        end
        function x = atan(x)
            x.data = atan(x.data);
            x = mytrim(x);
        end
        function x = atan2(x)
            x.data = atan2(x.data);
            x = mytrim(x);
        end
        function x = ceil(x)
            x.data = ceil(x.data);
        end
        function x = complex(x)
            x.data = complex(x.data);
        end
        function x = cos(x)
            x.data = cos(x.data);
            x = mytrim(x);
        end
        function x = eq(a,b)
            x = binop(@eq,a,b);
        end
        function x = exp(x)
            x.data = exp(x.data);
            x = mytrim(x);
        end
        function x = fix(x)
            x.data = fix(x.data);
            x = mytrim(x);
        end
        function x = floor(x)
            x.data = floor(x.data);
        end
        function x = ge(a,b)
            x = binop(@ge,a,b);
        end
        function x = gt(a,b)
            x = binop(@gt,a,b);
        end
        function x = imag(x)
            x = unop(@imag,x,0);
            x = mytrim(x);
        end
        function x = isinf(x)
            x.data = isinf(x.data);
        end
        function x = isnan(x)
            x.data = isnan(x.data);
        end
        function flag = isreal(x)
            flag = isreal(x.data);
        end
        function x = ldivide(a,b)
            x = binop(@ldivide,a,b);
        end
        function x = le(a,b)
            x = binop(@le,a,b);
        end
        function x = log(x)
            x.data = log(x.data);
            x = mytrim(x);
        end
        function x = log10(x)
            x.data = log10(x.data);
            x = mytrim(x);
        end
        function x = lt(a,b)
            x = binop(@lt,a,b);
        end
        function x = minus(a,b)
            x = binop(@minus,a,b);
        end
        function x = mldivide(x,y)
            if (isa(x,'tseries') && isa(y,'tseries')) ...
                    || (isnumeric(y) && length(y) == 1)
                x = binop(@ldivide,x,y);
            else
                x = binop(@mldivide,x,y);
            end
        end
        function x = mpower(x,y)
            x = binop(@power,x,y);
        end
        function x = mrdivide(x,y)
            if (isa(x,'tseries') && isa(y,'tseries')) ...
                    || (isnumeric(x) && length(x) == 1)
                x = binop(@rdivide,x,y);
            else
                x = binop(@mrdivide,x,y);
            end
        end
        function x = mtimes(x,y)
            if isa(x,'tseries') && isa(y,'tseries')
                x = binop(@times,x,y);
            else
                x = binop(@mtimes,x,y);
            end
        end
        function x = nanmean(x,dim)
            if nargin < 2
                dim = 1;
            end
            x = unop(@tseries.mynanmean,x,dim,dim);
        end
        function This = nanstd(This,Flag,Dim)
            if nargin < 2
                Flag = 0;
            end
            if nargin < 3
                Dim = 1;
            end
            This = unop(@tseries.mynanstd,This,Dim,Flag,Dim);
        end
        function This = nansum(This,Dim)
            if nargin < 2
                Dim = 1;
            end
            This = unop(@tseries.mynansum,This,Dim,Dim);
        end
        function This = nanvar(This,Flag,Dim)
            if nargin < 2
                Flag = 0;
            end
            if nargin < 3
                Dim = 1;
            end
            This = unop(@tseries.mynanvar,This,Dim,Flag,Dim);
        end
        function This = ne(This,Y)
            This = binop(@ne,This,Y);
        end
        function x = norm(x,varargin)
            x = norm(x.data,varargin{:}) ;
        end
        function x = not(x)
            x.data = not(x.data);
        end
        function x = or(x,y)
            x = binop(@or,x,y);
        end
        function x = plus(x,y)
            x = binop(@plus,x,y);
        end
        function x = power(x,y)
            x = binop(@power,x,y);
        end
        function x = prod(x,dim)
            if nargin < 2
                dim = 1;
            end
            x = unop(@prod,x,dim,dim);
        end
        function x = rdivide(x,y)
            x = binop(@rdivide,x,y);
        end
        function x = real(x)
            x.data = real(x.data);
            x = mytrim(x);
        end
        function x = sin(x)
            x.data = sin(x.data);
            x = mytrim(x);
        end
        function x = sqrt(x)
            x.data = sqrt(x.data);
            x = mytrim(x);
        end
        function x = tan(x)
            x.data = tan(x.data);
            x = mytrim(x);
        end
        function x = times(x,y)
            x = binop(@times,x,y);
        end
        function x = uminus(x)
            x.data = -x.data;
        end
        function x = uplus(x)
        end
        
        % Distribution functions (Stats Toolbox)
        %----------------------------------------
        function x = normcdf(x,varargin)
            x.data = normcdf(x.data,varargin{:});
            x = mytrim(x);
        end
        function x = normpdf(x,varargin)
            x.data = normpdf(x.data,varargin{:});
            x = mytrim(x);
        end
        function x = norminv(x,varargin)
            x.data = norminv(x.data,varargin{:});
            x = mytrim(x);
        end
        function x = logncdf(x,varargin)
            x.data = logncdf(x.data,varargin{:});
            x = mytrim(x);
        end
        function x = lognpdf(x,varargin)
            x.data = lognpdf(x.data,varargin{:});
            x = mytrim(x);
        end
        function x = logninv(x,varargin)
            x.data = logninv(x.data,varargin{:});
            x = mytrim(x);
        end
        function x = gevcdf(x,varargin)
            x.data = gevcdf(x.data,varargin{:});
            x = mytrim(x);
        end
        function x = gevpdf(x,varargin)
            x.data = gevpdf(x.data,varargin{:});
            x = mytrim(x);
        end
        function x = gevinv(x,varargin)
            x.data = gevinv(x.data,varargin{:});
            x = mytrim(x);
        end
        
        
        % Functions whose behaviour depends on the dimension.
        function x = any(x,dim)
            if nargin < 2
                dim = 1;
            end
            x = unop(@any,x,dim,dim);
        end
        function x = all(x,dim)
            if nargin < 2
                dim = 1;
            end
            x = unop(@all,x,dim,dim);
        end
        function x = cumprod(x,dim)
            if nargin < 2
                dim = 1;
            end
            x = unop(@cumprod,x,0,dim);
        end
        function x = cumsum(x,dim)
            if nargin < 2
                dim = 1;
            end
            x = unop(@cumsum,x,0,dim);
        end
        function a = geomean(x,dim)
            if nargin < 2
                dim = 1;
            end
            a = unop(@geomean,x,dim,dim);
        end
        function x = max(x,dim)
            if nargin < 2
                dim = 1;
            end
            x = unop(@max,x,dim,[],dim);
        end
        function x = mean(x,dim)
            if nargin  < 2
                dim = 1;
            end
            x = unop(@mean,x,dim,dim);
        end
        function x = median(x,dim)
            if nargin  < 2
                dim = 1;
            end
            x = unop(@median,x,dim,dim);
        end
        function x = min(x,dim)
            if nargin < 2
                dim = 1;
            end
            x = unop(@min,x,dim,[],dim);
        end
        function x = mode(x,dim)
            if nargin  < 2
                dim = 1;
            end
            x = unop(@mode,x,dim,dim);
        end
        function x = prctile(x,p,dim)
            if nargin < 3
                dim = 1;
            end
            x = unop(@tseries.myprctile,x,dim,p,dim);
        end
        % Alias for prctile.
        function varargout = pctile(varargin)
            [varargout{1:nargout}] = prctile(varargin{:});
        end
        function x = std(x,flag,dim)
            if nargin < 2
                flag = 0;
            end
            if nargin < 3
                dim = 1;
            end
            x = unop(@std,x,dim,flag,dim);
        end
        function x = sum(x,dim)
            if nargin < 2
                dim = 1;
            end
            x = unop(@sum,x,dim,dim);
        end
        function x = var(x,flag,dim)
            if nargin < 2
                flag = 0;
            end
            if nargin < 3
                dim = 1;
            end
            x = unop(@var,x,dim,flag,dim);
        end
    
        % Indexing.
        function index = end(x,k,n) %#ok<INUSD>
            if k == 1
                index = x.start + size(x.data,1) - 1;
            else
                index = size(x.data,k);
            end
        end
        function n = numel(~,varargin)
            n = 1;
        end
        
    end
    
end