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
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% IRIS can only run in Matlab Release 2010a and higher.
if xxMatlabRelease() < 2010
    error('iris:startup',...
        'Sorry, <a href="http://www.iris-toolbox.com">The IRIS Toolbox</a> can only run in Matlab R2010a or higher.');
end

shutup = any(strcmpi(varargin,'-shutup'));

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
clear('functions');
passvalopt();
passvalopt();

% Reset the configuration file.
rehash();
irisreset();
config = irisget();

% Add IRIS extensions to Matlab Editor.
irisextensions();

if ~shutup
    % Delete progress message.
    progress(1:end) = sprintf('\b');
    fprintf(progress);
    doMessage();
end

% Nested functions.

%**************************************************************************
    function doMessage()
        
        % Intro message.
        fprintf( ...
            ['\t<a href="http://www.iris-toolbox.com">IRIS Toolbox</a> ', ...
            'version #%s.\n'],irisget('version'));
        fprintf('\tCheck out <a href="http://groups.google.com/group/iris-toolbox">IRIS Toolbox forum</a> and <a href="http://iris-toolbox.blogspot.com">IRIS Toolbox blog</a>.');
        fprintf('\n');
        fprintf('\tCopyright (c) 2007-%s <a href="https://code.google.com/p/iris-toolbox-project/wiki/ist">IRIS Solutions Team</a>.\n',datestr(now,'YYYY'));
        fprintf('\n');
        
        % IRIS root folder.
        fprintf('\tIRIS root: <a href="file:///%s">%s</a>.\n',root,root);
        
        % Report user config file used.
        fprintf('\tUser config file: ');
        if isempty(config.userconfigpath)
            fprintf('<a href="matlab: idoc config/irisuserconfighelp">No user config file found</a>.\n');
        else
            fprintf('<a href="matlab: edit %s">%s</a>.\n',config.userconfigpath,config.userconfigpath);
        end
        
        % TeX/LaTeX executables.
        fprintf('\tLaTeX binary files: ');
        if isempty(config.pdflatexpath)
            fprintf('<a href="matlab: edit .m">No TeX/LaTeX installation found</a>.\n');
        else
            tmppath = fileparts(config.pdflatexpath);
            fprintf('<a href="file:///%s">%s</a>.\n',tmppath,tmppath);
        end
        
        % Report the X12 version integrated with IRIS.
        fprintf('\t<a href="http://www.census.gov/srd/www/x12a/">X12 ARIMA</a>: ');
        fprintf('Build 192 of Version 0.3.\n');
        
        % Report IRIS folders removed.
        if ~isempty(removed)
            fprintf('\n\tSuperfluous IRIS folders removed from Matlab path:\n');
            for i = 1 : numel(removed)
                fprintf('\t* <a href="file:///%s">%s</a>\n', ...
                    removed{i},removed{i});
            end
        end
        
        fprintf('\n');
        
    end % doMessage().

end

% Subfunctions.

%**************************************************************************
function [Year,Ab] = xxMatlabRelease()

try
    s = ver('MATLAB');
    Year = sscanf(s.Release(3:6),'%g',1);
    if isempty(Year)
        Year = 0;
    end
    Ab = s.Release(7);
catch %#ok<CTCH>
    Year = 0;
    Ab = '';
end

end % xxMatlabRelease().