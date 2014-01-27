function D = lognormal(This,D,varargin)
% lognormal  Characteristics of log-normal distributions returned by filter of forecast.
%
% Syntax
% =======
%
%     D = lognormal(M,D,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model on which the `filter` or `forecast` function has
% been run.
%
% * `D` [ struct ] - Struct or database returned from the `filter`
% or `forecast` function.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Struct including new sub-databases with requested
% log-normal statistics.
%
% Options
% ========
%
% * `'fresh='` [ `true` | *`false`* ] - Output structure will include only
% the newly computed databases.
%
% * `'mean='` [ *`true`* | `false` ] - Compute the mean of the log-normal
% distributions.
%
% * `'median='` [ *`true`* | `false` ] - Compute the median of the log-normal
% distributions.
%
% * `'mode='` [ *`true`* | `false` ] - Compute the mode of the log-normal
% distributions.
%
% * `'prctile='` [ numeric | *[5,95]* ] - Compute the selected percentiles of
% the log-normal distributions.
%
% * `'prefix='` [ char | *'lognormal'* ] - Prefix used in the names of the
% newly created databases.
%
% * `'std='` [ *`true`* | `false` ] - Compute the std deviations of the
% log-normal distributions.
%
% Description
% ============
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('this',@ismodel);
pp.addRequired('data', ...
    @(x) isstruct(x) && isfield(x,'mean') && isfield(x,'std'));
pp.parse(This,D);

Opt = passvalopt('model.lognormal',varargin{:});

%**************************************************************************

preexist = fieldnames(D);
logList = This.name(This.log);
field = @(x) sprintf('%s%s%',Opt.prefix,x);

doInitStruct();
template = tseries();

for i = 1 : length(logList)
    name = logList{i};
    doPopulate();
end

if ~Opt.fresh 
    D = rmfield(D,preexist);
end

% Nested functions.

%**************************************************************************
    function doInitStruct()
        if Opt.median
            D.(field('median')) = struct();
        end
        if Opt.mode
            D.(field('mode')) = struct();
        end
        if Opt.mean
            D.(field('mean')) = struct();
        end
        if Opt.std
            D.(field('std')) = struct();
        end
        if ~isequal(Opt.prctile,false) && ~isempty(Opt.prctile)
            Opt.prctile = Opt.prctile(:).';
            Opt.prctile = round(Opt.prctile);
            Opt.prctile(Opt.prctile <= 0 | Opt.prctile >= 100) = [];
            D.(field('pct')) = struct();
        end
    end

%**************************************************************************
    function doPopulate()
        [expmu,range] = rangedata(D.mean.(name),Inf);
        if isempty(range)
            return
        end
        sgm = rangedata(D.std.(name),range);
        sgm = log(sgm);
        sgm2 = sgm.^2;
        co = comment(D.mean.(name));
        start = range(1);
        if Opt.median
            x = xxMedian(expmu,sgm,sgm2);
            D.(field('median')).(name) = replace(template,x,start,co);
        end
        if Opt.mode
            x = xxMode(expmu,sgm,sgm2);
            D.(field('mode')).(name) = replace(template,x,start,co);
        end
        if Opt.mean
            x = xxMean(expmu,sgm,sgm2);
            D.(field('mean')).(name) = replace(template,x,start,co);
        end
        if Opt.std
            x = xxStd(expmu,sgm,sgm2);
            D.(field('std')).(name) = replace(template,x,start,co);
        end
        if ~isequal(Opt.prctile,false) && ~isempty(Opt.prctile)
            x = [];
            for p = Opt.prctile
                x = [x,xxPrctile(expmu,sgm,sgm2,p/100)]; %#ok<AGROW>
            end
            co = repmat(co,1,length(Opt.prctile));
            D.(field('pct')).(name) = replace(template,x,start,co);
        end
    end

end

% Subfunctions.

%**************************************************************************
function X = xxMedian(ExpMu,~,~)
X = ExpMu;
end % xxMedian().

%**************************************************************************
function X = xxMode(ExpMu,~,Sgm2)
X = ExpMu ./ exp(Sgm2);
end % xxMode().

%**************************************************************************
function X = xxMean(ExpMu,~,Sgm2)
X = ExpMu .* exp(0.5*Sgm2);
end % xxMean().

%**************************************************************************
function X = xxStd(ExpMu,Sgm,Sgm2)
X = xxmean(ExpMu,Sgm,Sgm2) .* sqrt(exp(Sgm2)-1);
end % xxStd().

%**************************************************************************
function X = xxPrctile(ExpMu,Sgm,~,P)
A = -sqrt(2).*erfcinv(2*P);
X = exp(Sgm.*A) .* ExpMu;
end % doPrctile().