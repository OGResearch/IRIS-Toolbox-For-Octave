function irisstartup(varargin)
% irisstartup  Start an IRIS session.
%
% Syntax
% =======
%
%     irisstartup
%     irisstartup -shutup
%
% Description
% ============
%
% We recommend that you keep the IRIS root directory on the permanent
% Matlab search path. Each time you wish to start working with IRIS, you
% run `irisstartup` form the command line. At the end of the session, you
% can run [`irisfinish`](config/irisfinish) to remove IRIS
% subfolders from the temporary Matlab search path, and to clear persistent
% variables in some of the backend functions.
%
% The [`irisstartup`](config/irisstartup) performs the following steps:
%
% * Adds necessary IRIS subdirectories to the temporary Matlab search
% path.
%
% * Removes redundant IRIS folders (e.g. other or older installations) from
% the Matlab search path.
%
% * Resets IRIS configuration options to default, updates the location of
% TeX/LaTeX executables, and calls
% [`irisuserconfig`](config/irisuserconfighelp) to modify the configuration
% option.
%
% * Associates the default IRIS extensions with the Matlab Editor. If they
% had not been associated before, Matlab must be re-started for the
% association to take effect.
%
% * Prints an introductory message on the screen unless `irisstartup` is
% called with the `-shutup` input argument.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% IRIS can only run in Matlab Release 2010a and higher.
if ismatlab && xxMatlabRelease() < 2010
    error('iris:startup',...
        ['Sorry, <a href="http://www.iris-toolbox.com">The IRIS Toolbox</a> ', ...
        'can only run in Matlab R2010a or higher.']);
elseif ~ismatlab
    vv = xxOctaveRelease();
    if isempty(vv)
        error('iris:startup', 'Sorry, version of your system is unknown');
    elseif vv < 3771 % 3.7.7+, but it's gonna be 5.x.x most probably, as classdef branch is far from stable
        error('iris:startup', ['Sorry, The IRIS Toolbox ', ...
        'can only run in Octave 3.7.7+ or higher.']);
    end
    mlock; % temporary, while octave bug #35881 is not fixed
end

shutup = any(strcmpi(varargin,'-shutup'));
isIdChk = ~any(strcmpi(varargin,'-noidchk'));

if ~shutup
    progress = 'Starting up an IRIS session...';
    fprintf('\n');
    fprintf(progress);
end

% Get the whole IRIS folder structure. Exclude directories starting with an
% _ (on top of +, @, and private, which are excluded by default).
removed = irispathmanager('cleanup');
root = removed{1};
removed(1) = [];

% Add the current IRIS folder structure to the temporary search path.
addpath(root,'-begin');
irispathmanager('addroot',root);
irispathmanager('addcurrentsubs');

% Reset default options in `passvalopt`.
try %#ok<TRYNC>
    munlock('passvalopt');
end
try %#ok<TRYNC>
    munlock('irisconfigmaster');
end

% Reset the configuration file.
munlock irisconfigmaster;
clear functions;
irisreset(varargin{:});
config = irisget();

munlock passvalopt;
clear functions;
passvalopt();

version = irisget('version');
if isIdChk
    doIdChk();
end

if ~shutup
    % Delete progress message.
    doDeleteProgress();
    doMessage();
end


% Nested functions...


%**************************************************************************
    function doDeleteProgress()
        progress(1:end) = sprintf('\b');
        fprintf(progress); 
    end % doDeleteProgress()


%**************************************************************************
    function doMessage()
        
        % Intro message.
        if ismatlab
            fprintf('\t<a href="http://www.iris-toolbox.com">IRIS Toolbox</a> ');
            fprintf('Release %s.',version);
            fprintf('\n');
            fprintf('\tCopyright (c) 2007-%s ',datestr(now,'YYYY'));
            fprintf('<a href="https://code.google.com/p/iris-toolbox-project/wiki/ist">');
            fprintf('IRIS Solutions Team</a>.');
            fprintf('\n\n');
        else
            fprintf('%8sIRIS Toolbox ','');
            fprintf('Release %s, [FOR OCTAVE].',version);
            fprintf('\n');
            fprintf('\tCopyright (c) 2007-%s ',datestr(now,'YYYY'));
            fprintf('IRIS Solutions Team.');
            fprintf('\n\n');
        end
        
        % IRIS root folder.
        if ismatlab
            fprintf('\tIRIS root: <a href="file:///%s">%s</a>.\n',root,root);
        else
            fprintf('\tIRIS root: %s.\n',root);
        end
        
        % Report user config file used.
        fprintf('\tUser config file: ');
        if isempty(config.userconfigpath)
            if ismatlab
                fprintf('<a href="matlab: idoc config/irisuserconfighelp">');
                fprintf('No user config file found</a>.');
            else
                fprintf('No user config file found.');
            end
        else
            if ismatlab
                fprintf('<a href="matlab: edit %s">%s</a>.', ...
                    config.userconfigpath,config.userconfigpath);
            else
                fprintf(config.userconfigpath);
            end
        end
        fprintf('\n');
        
        % TeX/LaTeX executables.
        fprintf('\tLaTeX binary files: ');
        if isempty(config.pdflatexpath)
            if ismatlab
                fprintf('<a href="matlab: edit .m">');
                fprintf('No TeX/LaTeX installation found</a>.');
            else
                fprintf('No TeX/LaTeX installation found.');
            end
        else
            tmppath = fileparts(config.pdflatexpath);
            if ismatlab
                fprintf('<a href="file:///%s">%s</a>.',tmppath,tmppath);
            else
                fprintf(tmppath);
            end
        end
        fprintf('\n');
        
        % Report the X12 version integrated with IRIS.
        if ismatlab
            fprintf('\t<a href="http://www.census.gov/srd/www/x13as/">');
            fprintf('X13-ARIMA-SEATS</a>: ');
        else
            fprintf('\tX13-ARIMA-SEATS: ');
        end
        fprintf('Version 1.1 Build 9.');
        fprintf('\n');
        
        % Report IRIS folders removed.
        if ~isempty(removed)
            fprintf('\n');
            fprintf('\tSuperfluous IRIS folders removed from Matlab path:');
            fprintf('\n');
            for i = 1 : numel(removed)
                if ismatlab
                    fprintf('\t* <a href="file:///%s">%s</a>', ...
                        removed{i},removed{i});
                else
                    fprintf('\t* %s',removed{i});
                end
                fprintf('\n');
            end
        end
        
        fprintf('\n');
        
    end % doMessage()


%**************************************************************************
    function doIdChk()
        list = dir(fullfile(root,'iristbx*'));
        if length(list) == 1
            idFileVersion = strrep(list.name,'iristbx','');
            if ~strcmp(version,idFileVersion)
                doDeleteProgress();
                utils.error('irisstartup', ...
                    ['The IRIS version check file (%s) does not match ', ...
                    'the current version of IRIS (%s). ', ...
                    'Delete everything from the IRIS root folder, ', ...
                    'and reinstall IRIS.'], ...
                    idFileVersion,version);
            end
        elseif isempty(list)
            doDeleteProgress();
            utils.error('irisstartup', ...
                ['The IRIS version check file is missing. ', ...
                'Delete everything from the IRIS root folder, ', ...
                'and reinstall IRIS.']);
        else
            doDeleteProgress();
            utils.error('irisstartup', ...
                ['There are mutliple IRIS version check files ', ...
                'found in the IRIS root folder. This is because ', ...
                'you installed a new IRIS in a folder with an old ', ...
                'version, without deleting the old version first. ', ...
                'Delete everything from the IRIS root folder, ', ...
                'and reinstall IRIS.']);
        end
    end % doIdChk()


end


% Subfunctions...


%**************************************************************************


function [Year,Ab] = xxMatlabRelease()
Year = 0;
Ab = '';
try %#ok<TRYNC>
    s = ver('MATLAB');
    inx = strcmpi({s.Name},'MATLAB');
    if any(inx)
        s = s(find(inx,1));
        tok = regexp(s.Release,'R(\d{4})([ab])','tokens','once');
        if ~isempty(tok)
            Year = sscanf(tok{1},'%g',1);
            Ab = tok{2};
        end
    end
end
end % xxMatlabRelease()

function verNum = xxOctaveRelease()

try
    s = ver('OCTAVE');
    verVec = sscanf(s.Version,'%d.%d.%d%c');
    verNum = sum(reshape(verVec(1:3),1,[]).*[1e3 1e2 1e1]) + (length(verVec)>3);
catch %#ok<CTCH>
    verNum = [];
end

end % xxOctaveRelease()