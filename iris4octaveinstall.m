function iris4octaveinstall(varargin)

%% ADD IRIS TO THE LIST OF OCTAVE PACKAGES
%--------------------------------------------------------------------------
% process user options
% path to iris to be installed
ix = find(strcmpi(varargin,'path'),1,'last');
if ~isempty(ix) && (nargin > ix)
  path2iris = varargin{ix+1};
else
  path2iris = pwd();
end
% path to .octave_packages file
ix = find(strcmpi(varargin,'path_to_octave_packages'),1,'last');
if ~isempty(ix) && (nargin > ix)
  path2octPkg = varargin{ix+1};
else
  path2octPkg = pkg('local_list');
end
local_packages = {};

% check iris version
list = dir(fullfile(path2iris,'iristbx*'));
if length(list) == 1
  irisVer = strrep(list.name,'iristbx','');
elseif isempty(list)
  error(['The IRIS version check file is missing. ', ...
    'Delete everything from the IRIS root folder, ', ...
    'and reinstall IRIS.']);
else
  error(['There are mutliple IRIS version check files ', ...
    'found in the IRIS root folder. This is because ', ...
    'you installed a new IRIS in a folder with an old ', ...
    'version, without deleting the old version first. ', ...
    'Delete everything from the IRIS root folder, ', ...
    'and reinstall IRIS.']);
end

% load local_packages
if ~exist(path2octPkg,'file')
  warning('File "%s" doesn''t exist and will be created.',path2octPkg);
else
  load(path2octPkg);
end

if isstruct(local_packages)
  local_packages = {local_packages};
end

% find Iris's index in local_packages
nPkg = numel(local_packages);
ixIris = nPkg + 1;
for ix = 1 : nPkg
  if strcmpi(local_packages{ix}.name,'IRIS Toolbox')
    ixIris = ix;
    break
  end
end

% update Iris package info
pkgInfo = struct();
doUpdateIrisPkgInfo();

% upgrade local_packages and save in back to .octave_packages
local_packages{ixIris} = pkgInfo;
save(path2octPkg,'local_packages');


%% INSTALL "GENERAL" PACKAGE WITH NEW @INPUTPARSER
%--------------------------------------------------------------------------
% replace source file of "general" package with one containig new @inputParser
% (based on classdef syntax)
generalName = 'general-1.3.4.tar.gz';
generalSrc = fullfile(path2iris,'+irisroom','+iris4oct',generalName);
copyfile (generalSrc, fullfile(OCTAVE_HOME,'src'), 'f');

% install new "general" package
pkg('install', '-auto', fullfile(OCTAVE_HOME,'src',generalName));


%% CREATE ".OCTAVERC" FILE IN USER's DIRECTORY
%--------------------------------------------------------------------------
userDir = getenv('USERPROFILE');
rcfname = fullfile(userDir,'.octaverc');
if exist(rcfname,'file')
  copyfile(rcfname,[rcfname,'_backup']);
  warning('New ".octaverc" file is being created! Existing one was backed up.');
end
fid = fopen(rcfname,'w+');
fprintf(fid,'%s\n','page_screen_output (false);');
fprintf(fid,'%s\n','graphics_toolkit fltk');
fclose(fid);


%% PARSE ALL IRIS FILES AND MOSW-SWITCH THEM TO OCTAVE VERSION
%--------------------------------------------------------------------------
lst = irisroom.iris4oct.irisfulldirlist('files',true,'fileExt','.m');
for ix = 1 : numel(lst)
  filename = lst{ix};
  % parse ">>>>> MOSW" occurrences
  content = file2char(filename);
  content = regexprep(content,'(.*)( % >>>>> MOSW )(.*?)(\n.*)','$3$2$1$4');
  char2file(content,filename);
  % parse "##### MOSW" occurrences
  content = file2char(filename);
  content = strrep(content,'true % ##### MOSW','false % ##### MOSW');
  char2file(content,filename);
end


% Nested functions...


%**************************************************************************


  function doUpdateIrisPkgInfo
    pkgInfo.name = 'IRIS Toolbox';
    pkgInfo.version = irisVer;
    pkgInfo.date = datestr(now(),'yyyy-mm-dd');
    pkgInfo.author = 'IRIS Solutions Team';
    pkgInfo.maintainer = ['IRIS discussion forum community ', ...
      '<https://iristoolbox.codeplex.com/discussions>'];
    pkgInfo.title = 'IRIS Toolbox';
    pkgInfo.description = 'Toolbox for macroeconomic modelling and forecasting';
    pkgInfo.depends = {};
      pkgInfo.depends{1} = struct();
        pkgInfo.depends{1}.package = 'octave';
        pkgInfo.depends{1}.operator = '>=';
        pkgInfo.depends{1}.version = '4.1.0';
      pkgInfo.depends{2} = struct();
        pkgInfo.depends{2}.package = 'general';
        pkgInfo.depends{2}.operator = '>=';
        pkgInfo.depends{2}.version = '1.3.4';
    pkgInfo.autoload = 1;
    pkgInfo.license = 'BSD New';
    pkgInfo.url = 'http://iris-toolbox.com';
    pkgInfo.dir = path2iris;
    pkgInfo.archprefix = path2iris;
    pkgInfo.loaded = 1;
    
  end
  
end