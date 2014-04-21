function varargout = irisconfigmaster(Req,varargin)
% irisconfigmaster  [Not a public function ] The IRIS Toolbox master configuration file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

mlock();
persistent config;
if isempty(config)
    config = irisconfig();
end

%--------------------------------------------------------------------------

switch Req
    
    case 'get'
        if nargin == 1
            varargout{1} = rmfield(config,'protected');
        else
            notFound = {};
            n = length(varargin);
            varargout = cell(1,n);
            for i = 1 : n
                try
                    name = lower(varargin{i});
                    varargout{i} = config.(name);
                catch %#ok<CTCH>
                    notFound{end+1} = varargin{i}; %#ok<AGROW>
                    varargout{i} = NaN;
                end
            end
            if ~isempty(notFound)
                utils.warning('config',...
                    'This is not a valid IRIS config option: ''%s''.',...
                    notFound{:});
            end
        end
        
    case 'set'
        invalid = {};
        unable = {};
        for i = 1 : 2 : nargin-1
            name = lower(varargin{i});
            if any(strcmp(name,config.protected))
                unable{end+1} = varargin{i}; %#ok<AGROW>
            elseif isfield(config,name)
                value = varargin{i+1};
                if isfield(config.validate,name) ...
                        && ~config.validate.(name)(config.(name))
                    invalid{end+1} = name; %#ok<AGROW>
                else
                    config.(name) = value;
                end
            end
        end
        if ~isempty(unable)
            utils.warning('config', ...
                ['This IRIS config option is not customisable ', ...
                'and its value has not been changed: ''%s''.'], ...
                unable{:});
        end
        if ~isempty(invalid)
            utils.warning('config', ...
                ['The value supplied for this IRIS config option is invalid ', ...
                'and has not been assigned: ''%s''.'], ...
                invalid{:});
        end
        
    case 'reset'
        config = irisconfig();
    
    otherwise
        error('iris:config',...
            'Incorrect type or number of input or output arguments.');

end

end
