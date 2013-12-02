function varargout = irispathmanager(Req,varargin)
% irispathmanager  [Not a public function] IRIS path manager.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Folders not to be included in the Matlab path.
exclude = {'-','\+','\.'};
if ~ismatlab
  % Additionlly exclude for Octave version
  exclude4octave = {};
  exclude = [exclude exclude4octave];
end

switch lower(Req)
    case 'cleanup'
        % Remove all IRIS roots and subs found on the Matlab temporary
        % and permanent search paths.
        varargout{1} = {};
        list = which('irisstartup.m','-all');
        if ~ismatlab && ~iscell(list) % in Octave option -all is not working yet, so the result is [char] as in case w/o options
          list = {list};
        end
        for i = 1 : numel(list)
            root = fileparts(list{i});
            if isempty(root)
                continue
            end
            [root,subs] = xxGenPathCell(root,exclude);
            if root(end) == pathsep()
                root(end) = '';
            end
            if ~isempty(subs)
                xxRmPath(subs{:});
            end
            if ~isempty(root)
                xxRmPath(root);
            end
            varargout{1}{end+1} = root;
        end
        clear functions;
        rehash();
    case 'addroot'
        % Add the specified root to the temporary search paths.
        addpath(varargin{1},'-begin');
    case 'addcurrentsubs'
        % Add subfolders within the current root to the temporary
        % search path.
        root = which('irisstartup.m');
        root = fileparts(root);
        [root,subs] = xxGenPathCell(root,exclude); %#ok<ASGLU>
        if isempty(subs)
            subs = '';
        else
            subs = [subs{:}];
            addpath(subs,'-begin');
        end
        varargout{1} = subs;
    case 'removecurrentsubs'
        % Remove subfolders within the current root from the temporary
        % and permanent search paths.
        root = which('irisstartup.m');
        root = fileparts(root);
        [root,subs] = xxGenPathCell(root,exclude); %#ok<ASGLU>
        if isempty(subs)
            subs = '';
        else
            subs = [subs{:}];
            rmpath(subs{:});
            %xxRmPerm(subs);
            %xxRmTemp(subs);
        end
        varargout{1} = subs;
end

end

% Subfunctions.

%**************************************************************************
function xxRmPath(varargin)
status = warning('query','all');
if ismatlab
  warning('off','MATLAB:rmpath:DirNotFound');
else
  warning('off','Octave:rmpath:DirNotFound'); % this ID doesn't exist in Octave yet
end
rmpath([varargin{:}]);
warning(status);
end % xxRmPath().

%**************************************************************************
function [Root,P] = xxGenPathCell(Root,Exclude)
% Use `genpath` to generate path string and remove paths that include
% patterns specified in `exclude`.
P = genpath(Root);
if isempty(P)
    P = {};
    return
else
    % Break the path string into individual paths.
    P = regexp(P,['.*?',pathsep()],'match');
    if isempty(P)
        return
    else
        Root = P{1};
        P = P(2:end);
    end
end

if nargin > 1 && ~isempty(Exclude) && ~isempty(P)
    if ischar(Exclude)
        Exclude = {Exclude};
    end
    keep = true(size(P));
    % Length of the root string including the pathsep() at the end of it.
    % Later we remove `lenroot-1` characters from the individual paths.
    nRoot = length(Root);
    for i = 1 : length(P)
        % Remove the root from the i-th path, and only check for the
        % excluded patterns in the rest of the path. This is to handle
        % cases in which the root includes some of the excluded patterns
        % (we don't want to remove the root then).
        dirName = P{i};
        if length(dirName) >= nRoot ...
                && strncmpi(dirName,Root,nRoot-1)
            dirName(1:nRoot-1) = '';
        end
        for j = 1 : length(Exclude)
            keep(i) = keep(i) ...
                && isempty(regexp(dirName,Exclude{j},'once'));
            if ~keep(i)
                break
            end
        end
    end
    P = P(keep);
end
end % xxGenPathCell().