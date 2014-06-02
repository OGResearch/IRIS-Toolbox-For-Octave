function updateversion()

br = sprintf('\n');
xNow = now();
version = datestr(xNow,'yyyymmdd');
versionTime = datestr(xNow,'HH:MM:SS');

% Delete all version check files.
list = dir(fullfile(irisroot(),'iristbx*'));
for i = 1 : length(list)
    name = list(i).name;
    delete(fullfile(irisroot(),name));
end

% Create new version check file.
char2file('',fullfile(irisroot(),['iristbx',version]));

% Create IRIS Contents.m file.
c = '';
c = [c,'% IRIS Toolbox',br];
c = [c,'% Version ',version,' ',versionTime];
char2file(c,fullfile(irisroot(),'Contents.m'));

end