function iris4octaveinstall(varargin)

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
  path2octPkg = tilde_expand(fullfile('~','.octave_packages'));
end

% check iris version
list = dir(fullfile(root,'iristbx*'));
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
load(path2octPkg);
if isstruct(local_packages)
  local_packages = {local_packages};
end

% find Iris's index in local_packages
nPkg = numel(local_packages);
ixIris = nPkg + 1;
for ix = 1 : nPkg
  if strcpmi(local_packages{ix}.name,'iris_toolbox')
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

% Nested functions
  function doUpdateIrisPkgInfo
    pkgInfo.name = 'iris-toolbox';
    pkgInfo.version = irisVer;
    pkgInfo.date = datstr(now(),'yyyy-mm-dd');
    pkgInfo.author = 'IRIS Solutions Team';
    pkgInfo.maintainer = ['IRIS discussion forum community ', ...
      '<https://iristoolbox.codeplex.com/discussions>'];
    pkgInfo.title = 'IRIS Toolbox';
    pkgInfo.description = 'Toolbox for macroeconomic modelling and forecasting';
    pkgInfo.depends = {};
      pkgInfo.depends{1} = struct();
        pkgInfo.depends{1}.package = 'octave';
        pkgInfo.depends{1}.operator = '>=';
        pkgInfo.depends{1}.version = '3.7.7';
      pkgInfo.depends{2} = struct();
        pkgInfo.depends{2}.package = 'general';
        pkgInfo.depends{2}.operator = '>=';
        pkgInfo.depends{2}.version = '1.3.0';
    pkgInfo.autoload = 1;
    pkgInfo.license = 'BSD New';
    pkgInfo.url = 'http://iris-toolbox.com';
    pkgInfo.dir = path2iris;
    pkgInfo.archprefix = path2iris;
    pkgInfo.loaded = 1;
    
  end