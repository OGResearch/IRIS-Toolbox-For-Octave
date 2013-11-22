function [outputfile,c] = i2model(inputfile,outputfile)

if ~exist('outputfile','var')
   [fpath,ftitle] = fileparts(inputfile);
   outputfile = fullfile(fpath,[ftitle,'.model']);
end

c = file2char(inputfile);
c = strfun.removecomments(c);

% Find parameters name?p, name?p=0.5.
p = struct();
tokens = regexp(c,'(\<[A-Za-z]\w*\>)#p([\+\-\d\.]+)','tokens');
for i = 1 : length(tokens)
   if ~isfield(p,tokens{i}{1})
      p.(tokens{i}{1}) = NaN;
   end
   if ~isempty(tokens{i}{2})
      p.(tokens{i}{1}) = tokens{i}{2};
   end
end
plist = fieldnames(p);
np = length(plist);
pstring = cell([1,np]);
for i = 1 : np
   pstring{i} = plist{i};
   if ~isempty(p.(plist{i}))
      pstring{i} = [pstring{i},'=',p.(plist{i})];
   end
end
c = regexprep(c,'(\<[A-Za-z]\w*\>)#p([\+\-\d\.]+)','$1');
[plist,index] = sort(plist);
pstring = pstring(index);

% Find shocks name?x.
xlist = regexp(c,'\<[A-Za-z]\w*\>(?=#x)','match');
xlist = unique(xlist);
xlist = sort(xlist);
c = regexprep(c,'(\<[A-Za-z]\w*\>)#x','$1');

% List of all names in the code.
list = regexp(c,'\<[A-Za-z]\w*\>(?!\()','match');
list = unique(list);

list = setdiff(list,plist);
list = setdiff(list,xlist);
list = sort(list);

cslist = @(x) strfun.cslist(x,'lead','   ','wrap',75);
nl = sprintf('\n');
preamble = [ ...
   '!variables:transition',nl, ...
   cslist(list),nl,nl, ...
   '!shocks:transition',nl, ...
   cslist(xlist),nl,nl, ...
   '!parameters',nl, ...
   cslist(pstring),nl,nl, ...   
];

c = regexprep(c,'^(\s*?\n)*','');
c = regexprep(c,'(\s*?\n)*$','');
c = [preamble,'!equations:transition',nl,nl,strtrim(c)];

char2file(c,outputfile);

end