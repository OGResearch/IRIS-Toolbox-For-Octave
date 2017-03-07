function iris4octaveinstall(varargin)

fprintf('\nInstalling Iris for Octave...\n\n');

%% ADD IRIS TO THE LIST OF OCTAVE PACKAGES
%--------------------------------------------------------------------------
% process user options
% path to iris to be installed
fprintf('\tAdding IRIS to the list of Octave packages...\n');
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
  fprintf('\t\tFile "%s" doesn''t exist and will be created.\n',path2octPkg);
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

fprintf('\tAdded successfully!\n');

%% COMPILE MEX-FILES NEEDED FOR OCTAVE
%--------------------------------------------------------------------------
fprintf('\tCompiling libraries missing in Octave...\n');
% ordqz()
fprintf('\t\tORDQZ...\n');
mkoctfile(fullfile(path2iris,'+mosw','+octfun','mexSrc','myordqz.c'), ...
          '-o', fullfile(path2iris,'+mosw','+octfun','myordqz.mex'), ...
          '--mex', '-lblas', '-llapack');
fprintf('\t\tDone!\n');
% ordschur()
fprintf('\t\tORDSCHUR...\n');
mkoctfile(fullfile(path2iris,'+mosw','+octfun','mexSrc','myordschur.c'), ...
          '-o', fullfile(path2iris,'+mosw','+octfun','myordschur.mex'), ...
          '--mex', '-lblas', '-llapack');
fprintf('\t\tDone!\n');
fprintf('\tCompiled successfully!\n');

%% CREATE ".OCTAVERC" FILE IN USER's DIRECTORY
%--------------------------------------------------------------------------
fprintf('\tCreating ".octaverc" file in user''s folder...\n');
if ispc
  userDir = getenv('USERPROFILE');
else
  userDir = tilde_expand("~");
end
rcfname = fullfile(userDir,'.octaverc');
if exist(rcfname,'file')
  copyfile(rcfname,[rcfname,'_backup']);
  fprintf('\t\tExisting ".octaverc" file was backed up.\n');
end
fid = fopen(rcfname,'w+');
fprintf(fid,'%s\n','page_screen_output (false);');
fprintf(fid,'%s\n','graphics_toolkit qt');
fclose(fid);
% apply the settings right away
page_screen_output (false);
graphics_toolkit qt;
fprintf('\tCreated successfully!\n');

%% PARSE ALL IRIS FILES AND MOSW-SWITCH THEM TO OCTAVE VERSION
%--------------------------------------------------------------------------
%{
lst = irisroom.iris4oct.irisfulldirlist('files',true,'fileExt','.m');
addpath(fullfile(path2iris,'utils'));
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
rmpath(fullfile(path2iris,'utils'));
%}

fprintf('\nIris for Octave was successfully installed!\n\n');

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