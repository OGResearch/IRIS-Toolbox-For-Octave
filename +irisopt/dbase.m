function Def = dbase()
% dbase  [Not a public function] Default options for dbase functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def = struct();

dateformat = { ...
    'dateformat',@config,@config, ...
    'freqletters,freqletter',@config,@config, ...
    'months,month',@config,@config, ...
    'standinmonth',@config,@config, ...
    };

Def.dbbatch = {
    'append',[],@(x) isempty(x) || islogical(x), ...
    'classlist,classfilter',Inf,@(x) (isnumeric(x) && isinf(x)) || ischar(x) || iscellstr(x), ...
    'freqfilter',Inf,@isnumeric, ...
    'merge',[],@(x) isempty(x) || islogical(x), ...
    'namefilter','',@(x) isempty(x) || (isnumeric(x) && isinf(x)) || ischar(x), ...
    'namelist',Inf,@(x) (isnumeric(x) && isinf(x)) || ischar(x) || iscellstr(x), ...
    'fresh',false,@(x) islogical(x) || isstruct(x), ...
    'stringlist',{},@(x) iscellstr(x) || ischar(x), ...
    };

Def.dbload = { ...
    dateformat{:}, ...
    'case,changecase','',@(x) isempty(x) || any(strcmpi(x,{'lower','upper'})), ...
    'commentrow',{'comment','comments'},@(x) ischar(x) || iscellstr(x), ...
    'convert',[],@(x) (is.numericscalar(x) && any(x == [1,2,4,6,12,52])) ...
    || (iscell(x) && iscellstr(x(3:2:end)) && is.numericscalar(x{1}) && any(x{1} == [1,2,4,6,12,52]) && isnumeric(x{2})), ...
    'delimiter',',',@(x) ischar(x) && length(sprintf(x)) == 1, ...
    'firstdateonly',false,@(varargin)is.logicalscalar(varargin{:}), ...
    'inputformat','auto',@(x) ischar(x) && (strcmpi(x,'auto') || strcmpi(x,'csv') || strncmpi(x,'xl',2)), ...
    'namerow,leadingrow',{'','variables'},@(x) ischar(x) || iscellstr(x) || is.numericscalar(x), ...
    'namefunc',[],@(x) isempty(x) || is.func(x) || (iscell(x) && all(cellfun(@(varargin)is.func(varargin{:}),x))), ...
    'freq',[],@(x) isempty(x) || (ischar(x) && strcmpi(x,'daily')) || (length(x) == 1 && isnan(x)) || (isnumeric(x) && length(x) == 1 && any(x == [0,1,2,4,6,12,52,365])), ... 
    'nan','NaN',@(x) ischar(x), ...
    'preprocess',[],@(x) isempty(x) || is.func(x) || (iscell(x) && all(cellfun(@(varargin)is.func(varargin{:}),x))), ...
    'skiprows,skiprow','',@(x) isempty(x) || ischar(x) || iscellstr(x) || isnumeric(x), ...
    'userdata',Inf,@(x) isequal(x,Inf) || (ischar(x) && isvarname(x)), ...
    'userdatafield','.',@(x) ischar(x) && length(x) == 1, ...
    'userdatafieldlist',{},@(x) isempty(x) || iscellstr(x) || isnumeric(x), ...
    }; %#ok<CCAT>

Def.dbfun = { ...
    'cascade',true,@(varargin)is.logicalscalar(varargin{:}), ...
    'classlist,classfilter',Inf,@(x) (isnumeric(x) && isinf(x)) || ischar(x) || iscellstr(x), ...
    'fresh',false,@(varargin)is.logicalscalar(varargin{:}), ...
    'merge',[],@(x) isempty(x) || is.logicalscalar(x), ...
    'namelist',Inf,@(x) isequal(x,Inf) || iscellstr(x), ...
    'onerror','remove',@(x) ischar(x) && any(strcmpi(x,{'remove','keep','nan'})), ...
    'onwarning','nothing',@(x) ischar(x) && any(strcmpi(x,{'remove','keep','nan','nothing'})), ...
    };

Def.dbnames = { ...
    'classfilter',Inf,@(x) isequal(x,Inf) || ischar(x), ...
    'namefilter',Inf,@(x) isequal(x,Inf) || ischar(x), ...
    };

Def.dbprintuserdata = { ...
    'output','prompt',@(x) ischar(x) && any(strcmpi(x,{'html','prompt'})), ...
    };

Def.dbrange = { ...
    'startdate','maxrange',@(x) ischar(x) && any(strcmpi(x,{'maxrange','minrange','balanced','unbalanced'})), ...
    'enddate','maxrange',@(x) ischar(x) && any(strcmpi(x,{'maxrange','minrange','balanced','unbalanced'})), ...
    };

Def.dbsave = { ...
    dateformat{:}, ...
    'class',true,@(varargin)is.logicalscalar(varargin{:}), ...
    'comment',true,@(varargin)is.logicalscalar(varargin{:}), ...
    'decimal',[],@(x) isempty(x) || (length(x) == 1 && isnumeric(x)), ...
    'format','%.8e',@(x) ischar(x) && ~isempty(x) && x(1) == '%' ...
    && isempty(strfind(x,'$')) && isempty(strfind(x,'-')), ...
    'nan','NaN',@ischar, ...
    'savesubdb',false,@(varargin)is.logicalscalar(varargin{:}), ...
    'userdata','userdata',@(x) ischar(x) && isvarname(x), ...
    'delimiter', ',', @ischar, ...
    }; %#ok<CCAT>

Def.dbsplit = { ...
    'discard',true,@(varargin)is.logicalscalar(varargin{:}), ...
    };

Def.xls2csv = { ...
    'sheet',1,@(x) (is.numericscalar(x) && x == round(x) && x > 0) || ischar(x), ...
    };

end