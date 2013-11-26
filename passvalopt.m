function [Opt,varargout] = passvalopt(Spec,varargin)
% passvalopt  [Not a public function] Pass in and validate optional
% arguments. Initialise and permanently store default options for IRIS
% functions. If called with two output arguments, it passes out unused
% option names-values and does not throw a warning.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

persistent DEF;

if (nargin == 0 && nargout == 0) || isempty(DEF)
    % Initialise default options, and store them as a persistent struct.
    munlock();
    clear passvalopt;
    DEF = struct();
    DEF.dates = irisopt.dates();
    DEF.dbase = irisopt.dbase();
    DEF.dest = irisopt.dest();
    DEF.estimateobj = irisopt.estimateobj();
    DEF.FAVAR = irisopt.FAVAR();
    DEF.fragileobj = irisopt.fragileobj();
    DEF.freqdom = irisopt.freqdom();
    DEF.grfun = irisopt.grfun();
    DEF.iris = irisopt.IRIS();
    DEF.latex = irisopt.latex();
    DEF.likfunc = irisopt.likfunc();
    DEF.model = irisopt.model();
    DEF.modelobj = irisopt.modelobj();
    DEF.nnet = irisopt.nnet();
    DEF.optim = irisopt.optim();
    DEF.poster = irisopt.poster();
    DEF.preparser = irisopt.preparser();
    DEF.PVAR = irisopt.PVAR();
    DEF.qreport = irisopt.qreport();
    DEF.report = irisopt.report();
    DEF.sstate = irisopt.sstate();
    DEF.strfun = irisopt.strfun();
    DEF.SVAR = irisopt.SVAR();
    DEF.systempriors = irisopt.systempriors();
    DEF.tseries = irisopt.tseries();
    DEF.VAR = irisopt.VAR();
    DEF.varobj = irisopt.varobj();
    folderList = fieldnames(DEF);
    for i = 1 : length(folderList)
        funcList = fieldnames(DEF.(folderList{i}));
        for j = 1 : length(funcList)
            DEF.(folderList{i}).(funcList{j}) = ...
                xxConvert(DEF.(folderList{i}).(funcList{j}));
        end
    end
    mlock();
end

if nargout == 0
    return
elseif nargin == 0
    Opt = DEF;
    return
end

%--------------------------------------------------------------------------

if ischar(Spec)
    dotPos = strfind(Spec,'.');
    Spec = DEF.(Spec(1:dotPos-1)).(Spec(dotPos+1:end));
else
    Spec = xxConvert(Spec);
end

defaultName = Spec.name;
defaultPrimaryName = Spec.primaryname;
changed = Spec.changed;
validate = Spec.validate;
Opt = Spec.options;

% Return list of unused options.
varargout{1} = {};

if ~isempty(varargin)
    
    if iscellstr(varargin(1:2:end))
        % Called passvalopt(spec,'name',value,...).
        % This is the preferred way.
        userName = varargin(1:2:end);
        userValue = varargin(2:2:end);
        
    elseif nargin == 2 && isstruct(varargin{1})
        % Called passvalopt(spec,struct).
        userName = fieldnames(varargin{1});
        userValue = struct2cell(varargin{1})';
        
    elseif nargin == 2 && iscell(varargin{1});
        % Called passvalopt(spec,{'name',value}).
        userName = varargin{1}(1:2:end);
        userValue = varargin{1}(2:2:end);
    else
        utils.error('options', ...
            'Incorrect list of user options.');
    end
    
    if length(userName) > length(userValue)
        utils.error('options',...
            'No value assigned to the last option: ''%s''.', ...
            varargin{end});
    end
    
    % Remove non-alphanumeric characters from user names; this is primarily
    % meant to deal with the optional equal signs in option names.
    userName = regexp(userName,'[a-zA-Z]\w*','once','match');
    
    % List of primary option names specified by the user; this is used to check
    % conflicting options.
    userPrimaryName = {};
    
    for i = 1 : length(userName)
        if isempty(userName{i})
            continue
        end
        dotPos = strcmpi(userName{i},defaultName);
        if any(dotPos)
            pos = find(dotPos,1);
            name = defaultPrimaryName{pos};
            userPrimaryName{end+1} = name; %#ok<AGROW>
            Opt.(name) = userValue{i};
            changed.(name) = userName{i};
        else
            varargout{1}{end+1} = userName{i};
            varargout{1}{end+1} = userValue{i};
        end
    end
    
    if nargout == 1 && ~isempty(varargout{1})
        utils.error('options',...
            'Invalid or obsolete option: ''%s''.',...
            varargout{1}{1:2:end});
    end
    
    % Validate the user-supplied options; default options are NOT validated.
    invalid = {};
    name = fieldnames(Opt);
    for i = 1 : length(name)
        if isempty(changed.(name{i}))
            continue
        end
        if ~isempty(validate.(name{i}))
            if ~feval(validate.(name{i}),Opt.(name{i}))
                invalid{end+1} = changed.(name{i}); %#ok<AGROW>
                invalid{end+1} = func2str(validate.(name{i})); %#ok<AGROW>
            end
        end
    end
    
    if ~isempty(invalid)
        utils.error('options',...
            ['Value assigned to option ''%s='' ', ...
            'does not pass validation ''%s''.'],...
            invalid{:});
    end
    
end

end


% Subfunctions...


%**************************************************************************
function Y = xxConvert(X)

name = X(1:3:end);
nName = length(name);
name = regexp(name,'[a-zA-Z]\w*','match');
primaryName = {};
options = struct();
changed = struct();
validate = struct();

for i = 1 : nName
    n = length(name{i});
    % List of primary names.
    primaryName = [primaryName,name{i}(ones(1,n))]; %#ok<AGROW>
    options.(name{i}{1}) = X{(i-1)*3+2};
    % If this option is changed, save the exact name the user used so that an
    % error can refer to it should the user value fail to validate.
    changed.(name{i}{1}) = '';
    % Anonymous functions to validate user supplied values.
    validate.(name{i}{1}) = X{(i-1)*3+3};
end
% List of all possible names; name{i} maps into primaryname{i}.
name = [name{:}];

Y = struct();
Y.name = name; % List of all possible option names.
Y.primaryname = primaryName; % List of corresponding primary names.
Y.options = options; % Struct with primary names and default values.
Y.changed = changed; % Struct with empty chars, to be filled with the names used actually by the user.
Y.validate = validate; % Struct with validating functions.

end % xxConvert()