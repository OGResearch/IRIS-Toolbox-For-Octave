function x = converteols(x)
%x = regexprep(x,'\r\n?','\n');
% This is much faster:
% Windows:
x = strrep(x,sprintf('\r\n'),sprintf('\n'));
% Apple:
x = strrep(x,sprintf('\r'),sprintf('\n'));
end