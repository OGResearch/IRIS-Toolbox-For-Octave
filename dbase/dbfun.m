function [X,Flag,ErrList,WarnList] = dbfun(Func,D,varargin)
% dbfun  Apply a function to database fields.
%
% Syntax
% =======
%
%     [D,Flag,ErrList,WarnList] = dbfun(Func,D1,...)
%     [D,Flag,ErrList,WarnList] = dbfun(Func,D1,D2,...)
%
% Input arguments
% ================
%
% * `Func` [ function_handle | char ] - Function that will be applied to
% each field.
%
% * `D1` [ struct ] - Input database.
%
% * `D2`, `D3`, ... [ struct ] - Further input databases when `Func`
% accepts two input arguments.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database whose fields will be created by
% applying `Func` to each field of the input database or databases.
%
% * `Flag` [ `true` | `false` ] - True if no error occurs when evaluating
% the function.
%
% * `ErrList` [ cellstr ] - List of fields on which the function has thrown
% an error.
%
% * `WarnList` [ cellstr ] - List of fields on which the function has
% thrown a warning.
%
% Options
% ========
%
% * `'cascade='` [ *`true`* | `false` ] - Cascade through subdatabases
% applying the function `Func` to their fields, too.
%
% * `'classList='` [ cell | cellstr | *`Inf`* ] - Apply `Func` only to the
% fields of specified classes.
%
% * `'fresh='` [ `true` | *`false`* ] - Keep uprocessed fields in the output
% database.
%
% * `'nameList='` [ cell | cellstr | *`Inf`* ] - Apply `Func` only to the
% specified field names; can be still combined with the option
% `'classList='`.
%
% * `'onError='` [ `'keep'` | `'NaN'` | *`'remove'`* ]
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Parse input arguments.
pp = inputParser();
pp.addRequired('Func',@(x) is.func(x) || ischar(x));
pp.addRequired('D',@isstruct);
pp.parse(Func,D);


% Find last database in varargin
last = find(cellfun(@isstruct,varargin),1,'last') ;
if isempty(last)
    last = 0;
end

opt = passvalopt('dbase.dbfun',varargin{last+1:end});
doOptions();

%--------------------------------------------------------------------------

if isequal(opt.namelist,Inf)
    list = fieldnames(D);
else
    list = opt.namelist;
end

if opt.fresh
    X = struct();
else
    X = D;
end

Flag = true;
ErrList = {};
WarnList = {};
for i = 1 : length(list)
    if isa(D.(list{i}),'struct')
        % Process subdatabases
        %----------------------
        if ~opt.cascade
            % If not cascading, include the unprocessed subdatabase from the
            % first input database in the output database only if the option
            % `'fresh='` is false.
            if ~opt.fresh
                X.(list{i}) = D.(list{i});
            end
            continue
        end
        argList = doGetArgList();
        if all(cellfun(@(xArg)isa(xArg,'struct'),argList))
            X.(list{i}) = dbfun(Func,argList{:}, ...
                'classlist=',opt.classlist, ...
                'fresh=',opt.fresh);
        else
            X.(list{i}) = struct();
        end
        continue
    end
    if ~isequal(opt.classlist,Inf) ...
            && ~any(strcmp(class(D.(list{i})),opt.classlist))
        % This field fails to pass the class test.
        continue
    end
    % Process this field
    %--------------------
    try
        argList = doGetArgList();
        lastwarn('');
        X.(list{i}) = Func(argList{:});
        if ~isempty(lastwarn())
            doWhenWarning();
        end
    catch %#ok<CTCH>
        doWhenError();
    end
end


% Nested functions.


%**************************************************************************
    function doWhenError()
        ErrList{end+1} = list{i};
        switch lower(opt.onerror)
            case 'nan'
                X.(list{i}) = NaN;
            case 'keep'
                X.(list{i}) = D.(list{i});
            case 'remove'
                if isfield(X,list{i})
                    X = rmfield(X,list{i});
                end
        end
    end % doWhenError().


%**************************************************************************
    function doWhenWarning()      
        WarnList{end+1} = list{i};
        utils.warning('dbase', ...
            'The above warning occured when processing database field ''%s''.', ...
            list{i});
        switch lower(opt.onwarning)
            case 'nothing'
                % Do nothing, use whatever the function `Func` has returned.
            case 'nan'
                X.(list{i}) = NaN;
            case 'keep'
                X.(list{i}) = D.(list{i});
            case 'remove'
                if isfield(X,list{i})
                    X = rmfield(X,list{i});
                end
        end
    end % doWhenWarning().


%**************************************************************************
    function Arglist = doGetArgList()
        Arglist = cell(1,last+1);
        Arglist{1} = D.(list{i});
        for k = 1 : last
            Arglist{k+1} = varargin{k}.(list{i});
        end
    end % doGetArgList().


%**************************************************************************
    function doOptions()        
        if ischar(opt.classlist)
            opt.classlist = regexp(opt.classlist,'\w+','match');
        end
        if ischar(opt.namelist)
            opt.namelist = regexp(opt.namelist,'\w+','match');
        end
        % Bkw compatibility.
        if ~isempty(opt.merge)
            opt.fresh = ~opt.merge;
        end
    end % doOptions().


end