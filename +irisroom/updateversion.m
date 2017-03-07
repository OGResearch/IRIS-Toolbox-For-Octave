function Ver = updateversion(Suffix)
% updateversion  [Not a public function] Update IRIS release number.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    Suffix; %#ok<VUNUS>
catch
    Suffix = '';
end

br = sprintf('\n');
xNow = now();
Ver = [datestr(xNow,'yyyymmdd'),Suffix];
verTime = datestr(xNow,'HH:MM:SS');

% Delete all version check files.
list = dir(fullfile(irisroot(),'iristbx*'));
for i = 1 : length(list)
    name = list(i).name;
    delete(fullfile(irisroot(),name));
end

% Create new version check file.
char2file('',fullfile(irisroot(),['iristbx',Ver]));

% Create IRIS Contents.m file.
c = '';
c = [c,'% IRIS Toolbox',br];
c = [c,'% Version ',Ver,' ',verTime];
char2file(c,fullfile(irisroot(),'Contents.m'));

end