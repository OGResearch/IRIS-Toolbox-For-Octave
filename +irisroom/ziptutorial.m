function ziptutorial(Archive)
% zip  [Not a public function] Zip tutorial for distribution.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Zips the tutorial in the current working directory, and saves to Archive.

Ver = datestr(now(),'yyyymmdd');
[~,name] = fileparts(pwd());

name = fullfile(Archive,[name,'_',Ver,'.zip']);

list = zip(name, ...
    {'*.model','*.m','*.mat','*.csv','*.xls','*.pdf','*.q','*.tex'});
disp(char(list));
disp(' ');
disp(name);

end