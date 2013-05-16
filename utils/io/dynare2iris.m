function logbook = dynare2iris(inputfile,outputfile)

inputfile = strtrim(inputfile);
outputfile = strtrim(outputfile);

% read input file
fid = fopen(inputfile,'r');
if fid == -1
  if exist(inputfile,'file') == false, error('Unable to find ''%s''.',inputfile);
    else, error('Unable to open ''%s'' for reading.',inputfile); end
end
code = transpose(fread(fid,'*char'));

[fpath,ftitle,fext] = fileparts(outputfile);
if strcmp(fext,'.log'), fext = '.log~';
  else fext = '.log'; end
logfile = fullfile(fpath,[ftitle,fext]);

logbook = sprintf('Logfile for Dynare [%s] to IRIS [%s] conversion\n',inputfile,outputfile);
logbook = [logbook,sprintf('This logfile has been saved as %s\n\n',logfile)];

% Remove line comments.
code = regexprep(code,'//(.*?\n)','');

% Convert char(10) to white space.
code = strfun.converteols(code);

% remove multiple white characters
code = regexprep(code,'\s+',' ');

% Linear model.
tmp = length(code);
code = regexprep(code,'model\(linear\)','model');
islinear = length(code) < tmp;

% Transition variables (may also include shocks!) from INITVAL SECTION
% steady state expressions are copied without check.
aux = regexpi(code,'initval;(.*?)end;','tokens','once');
tokens = regexp(aux{1},'(\s*\w*\s*)=\s*(.*?);','tokens');
vtnames1 = {};
vtlist = '';
for i = 1 : length(tokens)
  vtnames1{end+1} = strtrim(tokens{i}{1});
  vtlist = [vtlist,sprintf('%s = %s;',tokens{i}{1:2})];
end

% transition variables from VAR section
tokens = regexpi(code,'var\s*(.*?);','tokens','once');
vtnames2 = regexp(tokens{1},'\w*','match');

% add transition variables from VAR section missing from INITVAL section
if length(vtnames2) > length(vtnames1)
  index = strfun.findnames(vtnames1,vtnames2);
  for i = find(isnan(index))
    vtlist = [vtlist,vtnames2{i},char(10)];
  end
end

% parameters
palist = regexpi(code,'parameters[^;]*;(.*?)model;','tokens','once');
palist = palist{1};
% remove TUNE_ and _TUNE
palist = regexprep(palist,'\<TUNE_\w*\>\s*=\s*[\+-\d\.]\s*;','','ignorecase');
palist = regexprep(palist,'\<\w*_TUNE\>\s*=\s*[\+-\d\.]\s*;','','ignorecase');

% transition equations
etlist = regexpi(code,'model;(.*?)end;','tokens','once');
etlist = etlist{1};
% replace time indices
etlist = regexprep(etlist,'(?<=\w)\(([\+-]?\d*)\)','{$1}');
% remove tunes
etlist = regexprep(etlist,'\<TUNE_\w*\>','0','ignorecase');
etlist = regexprep(etlist,'\<\w*_TUNE\>','0','ignorecase');

% residuals: varexo section
tokens = regexpi(code,'varexo\s*(.*?);','tokens','once');
namelist = regexp(tokens{1},'\w*','match');
vrlist = tokens{1};

% residuals: shocks section
section = regexpi(code,'shocks;(.*?)end;','tokens','once');
if ~isempty(section)
  section = section{1};
  output = regexpi(section,'var\s*(?<name>\w*\s*);\s*(?<std>stderr\s*[\+-\d\.]*\s*;)?','names');
  namelist0 = {output.name};
  index = strfun.findnames(namelist,namelist0);
  if any(isnan(index)) || length(namelist) ~= length(namelist0)
    error('VAREXO and SHOCKS sections must contain identical variables.');
  end
  stdlist = {output.std};
  stdlist = regexprep(stdlist,'stderr\s*','');
  % add std_ to parameter list and assign their values
  for i = 1 : length(namelist0)
    if ~isempty(stdlist{i})
      palist = [palist,sprintf('std_%s = %s',namelist0{i},stdlist{i})];
    end
  end
  % cross-covariances ignored --> logbook
  match = regexpi(section,'var\s*\w+\s*,\s*\w+\s*=.*?;','match');
  for i = 1 : length(match)
    logbook = [logbook,sprintf('Cross-covariance ignored:\n  %s\n',match{i})];
  end
else
  stdlist = {};
end

% Remove residuals from transition variables (they were on the
% INITVAL list) and parameters.
for i = 1 : length(namelist)
  % Remove residuals from transition variables.
  aux = regexp(vtlist,['(\<',namelist{i},'\>\s*=\s*[\+-]?[\d\.]*\s*;)'],'match');
  tmpvalues = regexp(aux,'.*?=(.*?);','tokens','once'); 
  tmpvalues = [tmpvalues{:}];
  for j = 1 : length(aux)
    if str2num(tmpvalues{j}) ~= 0
       logbook = [logbook,...
       sprintf('This steady-state value cannot be assigned because the variable is declared as a residual (residuals are always zero in steady state in IRIS):\n  %s\n',aux{j})];
    end
  end
  vtlist = regexprep(vtlist,['(\<',namelist{i},'\>\s*=\s*[\+-]?[\d\.]*\s*;)'],'');
end

% Create and save IRIS code.
code = '';
if islinear
   code = [code,'!linear',char(10),char(10)];
end
code = [code,...
  '!variables:transition',char(10),vtlist,char(10),...
  '!variables:residual',char(10),vrlist,char(10),char(10),...
  '!parameters',char(10),palist,char(10),...
  '!equations:transition',char(10),etlist,char(10),...
];
code = regexprep(code,';',sprintf(';\n'));
code = regexprep(code,'(\n)\s*','$1  ');
code = regexprep(code,'(\n)\s*!','$1$1!');

timestamp = datestr(now);
code = [sprintf('%% Based on Dynare file %s.\n%% Converted %s.\n\n',inputfile,timestamp),code];
logbook = [logbook,sprintf('\nConverted %s.',datestr(now))];

char2file(code,outputfile);
char2file(logbook,logfile);

end