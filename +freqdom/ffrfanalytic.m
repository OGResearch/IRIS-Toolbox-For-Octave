function [f,s] = ffrfanalytic(process)

if ~ischar(process)
   error('Incorrect type(s) of input argument(s).');
end

comp = regexp(process,'\{\s*(.*?)\s*\}','tokens');
comp = [comp{:}];
icomp = strrep(comp,'L','(1/L)');

numer = sprintf('s1^2*(%s)*(%s)',comp{1},icomp{1});
denom = numer;
for i = 2 : length(comp)
   denom = [denom,' + ',sprintf('(s%g^2)*(%s)*(%s)',i,comp{i},icomp{i})];
end
f = sprintf('(%s)/(%s)',numer,denom);

% Simplify expression for freq response.
s = f;
f = char(simplify(sym(f)));

% Vectorise *, /, \, ^ operators.
f = strfun.vectorise(f);

f = regexprep(f,'s(\d+)','s($1)');
f = strrep(f,'L','exp(-1i*freq)');
f = str2func(['@(freq,s)',f]);

end
