function Text = grabtext(StartTag,EndTag)
% grabtext  Retrieve the specified block comment from m-file caller.
%
% Syntax
% =======
%
%     C = strfun.grabtext(StartTag,EndTag)
%
% Input arguments
% ================
%
% * `StartTag` [ char ] - Start tag.
%
% * `EndTag` [ char ] - End tag.
%
% Output arguments
% =================
%
% * `C` [ char ] - Block comment with `StartTag` at the first line, and
% `EndTag` at the last line.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Text = '';

% Determine the name of the calling m-file.
stack = dbstack('-completenames');
if length(stack) < 2
   return
end
filename = stack(2).file;

% Read the m-file and convert all end-of-lines to \n.
file = file2char(filename);
file = strfun.converteols(file);

% Find the text between %{\nStartTag ... EndTag\n%}.
ptn = ['%\{\n+',StartTag,'\n(.*?)\n',EndTag,'\n+%\}'];
tkn = regexp(file,ptn,'once','tokens');
if isempty(tkn)
    return
end
Text = tkn{1};

end