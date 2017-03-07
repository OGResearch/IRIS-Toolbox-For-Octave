function varargout = request(action,varargin)
% request  [Not a public function] Persistent repository for container class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

mlock();
persistent X;

if isempty(X)
    % @@@@ MOSW
    X = struct();
    X.name = cell(1,0);
    X.data = cell(1,0);
    X.lock = false(1,0);
end

%--------------------------------------------------------------------------

switch action
    case 'get'
        index = strcmp(X.name,varargin{1});
        if any(index)
            varargout{1} = X.data{index};
            varargout{2} = true;
        else
            varargout{1} = [];
            varargout{2} = false;
        end
    case 'set'
        index = strcmp(X.name,varargin{1});
        if any(index)
            if X.lock(index)
                varargout{1} = false;
            else
                X.data{index} = varargin{2};
                varargout{1} = true;
            end
        else
            X.name{end+1} = varargin{1};
            X.data{end+1} = varargin{2};
            X.lock(end+1) = false;
            varargout{1} = true;
        end
    case 'list'
        varargout{1} = X.name;
    case {'lock','unlock'}
        tmp = strcmp(action,'lock');
        if isempty(varargin)
            X.lock(:) = tmp;
        else
            index = doFindNames(X,varargin);
            X.lock(index) = tmp;
        end
    case 'islocked'
        index = doFindNames(X,varargin);
        varargout{1} = X.lock(index);
    case 'locked'
        varargout{1} = X.name(X.lock);
    case 'unlocked'
        varargout{1} = X.name(~X.lock);
    case 'clear'
        % @@@@@ MOSW
        X = struct();
        X.name = cell(1,0);
        X.data = cell(1,0);
        X.lock = false(1,0);
    case 'save'
        if nargin > 1
            index = doFindNames(X,varargin);
            x = struct();
            x.name = X.name(index);
            x.data = X.data(index);
            x.lock = X.lock(index);
            varargout{1} = x;
        else
            varargout{1} = X;
        end
    case 'load';
        index = strfun.findnames(X.name,varargin{1}.name,'[^\s,;]+');
        new = isnan(index);
        nnew = sum(new);
        X.name(end+(1:nnew)) = varargin{1}.name(new);
        X.data(end+(1:nnew)) = varargin{1}.data(new);
        X.lock(end+(1:nnew)) = varargin{1}.lock(new);
        index = index(~new);
        if any(X.lock(index))
            index = index(X.lock(index));
            container.error(1,X.name(index));
        end
        X.data(index) = varargin{1}.data(~new);
    case 'remove'
        if ~isempty(varargin)
            index = doFindNames(X,varargin);
            X.name(index) = [];
            X.data(index) = [];
            X.lock(index) = [];
        end
    case 'count'
        varargout{1} = numel(X.name);
    case '?name'
        varargout{1} = X.name;
    case '?data'
        varargout{1} = X.data;
    case '?lock'
        varargout{1} = X.lock;
end

XX = X;

% Nested functions...


%**************************************************************************


    function Inx = doFindNames(X,Select)
        Inx = strfun.findnames(X.name,Select,'[^\s,;]+');
        if any(isnan(Inx))
            container.error(2,Select(isnan(Inx)));
        end
    end % doFindNames()


end
