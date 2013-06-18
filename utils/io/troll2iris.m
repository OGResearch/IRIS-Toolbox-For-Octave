function iris = troll2iris(trollfname,irisfname,varargin)
% troll2iris  Convert Troll model input file to IRIS model code.
%
% iris = troll2iris(trollfname,irisfname)
% Arguments:
%     iris char, trollfname char, irisfname char
%
% IR!S Toolbox 2005/12/21 

troll = file2char(trollfname);

troll = strfun.converteols(troll);
if troll(end) ~= char(10), troll(end+1) = char(10); end

% remove comments
% troll = regexprep(troll,'//.*?\n','\n');
troll = regexprep(troll,'//','%');

startmodel = NaN;
endmodel = NaN;
rows = {};
while ~isempty(troll)
  newline = find(troll == char(10),1);
  rows{end+1} = troll(1:newline);
  match = regexp(rows{end},'\s*>>\s*addeq','match');
  if ~isempty(match) && isnan(startmodel), startmodel = length(rows) + 1; end
  match = regexp(rows{end},'\s*>>\s*;','match');
  if ~isempty(match) && isnan(endmodel) && ~isnan(startmodel), endmodel = length(rows) - 1; end
  if isnan(startmodel) || ~isnan(endmodel)
    rows{end} = ['%',rows{end}];
  else
    rows{end} = strrep(rows{end},',',';');
    rows{end} = strrep(rows{end},'>>','');
  end
  troll = troll(newline+1:end);
end

code = [rows{startmodel:endmodel}];

% user modifications (function handles)
for i = 1 : nargin-2
  code = varargin{i}(code);
end

% remove labels
code = regexprep(code,'(\w+):','"$1"');

% find endogenous names
endog = regexpi(code,'(\w+)''n','tokens');
endog = unique([endog{:}]);
code = strrep(code,'''n','');

% find parameter names
param = regexpi(code,'(\w+)''p','tokens');
param = unique([param{:}]);
code = strrep(code,'''p','');

code0 = code;
for i = 1 : length(endog)
  code0 = regexprep(code0,['\<',endog{i},'\>'],'');
end
for i = 1 : length(param)
  code0 = regexprep(code0,['\<',param{i},'\>'],'');
end
code0 = regexprep(code0,'%.*?\n','\n');
resid = unique(regexp(code0,'[a-zA-z](\w*)','match'));

% replace time subscripts
code = regexprep(code,'\w\(([-\+]?\d*)\)','{$1}');

code = regexprep(code,'exp\(','@exp(','ignorecase');
code = regexprep(code,'log\(','@log(','ignorecase');
code = regexprep(code,'sqrt\(','@sqrt(','ignorecase');

endog_declare = sprintf('@variables:transition\n%s\n\n',sprintf('%s ',endog{:}));
resid_declare = sprintf('@variables:residual\n%s\n\n',sprintf('%s ',resid{:}));
param_declare = sprintf('@parameters\n%s\n\n',sprintf('%s ',param{:}));

iris = [endog_declare,resid_declare,param_declare,sprintf('@equations:transition\n\n'),code];

char2file(iris,irisfname);

end