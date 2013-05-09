function text = grabtext(startTag,endTag)
% grabtext  Retrieve the specified block comment from m-file caller.
%
% Syntax
% =======
%
%     C = strfun.grabtext(STARTTAG,ENDTAG)
%
% Input arguments
% ================
%
% * `STARTTAG` [ char ] - Start tag.
%
% * `ENDTAG` [ char ] - End tag.
%
% Output arguments
% =================
%
% * `C` [ char ] - Block comment with `STARTTAG` at the first line, and
% `ENDTAG` at the last line.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

text = '';

% Determine the name of the calling m-file.
stack = dbstack('-completenames');
if length(stack) < 2
   return
end
filename = stack(2).file;

% Read the m-file and find the text between %{\nSTARTTAG and ENDTAG\n%}.
file = file2char(filename);
file = strfun.converteols(file);
tokens = regexp(file,['%\{\n+',startTag,'\n(.*?)\n',endTag,'\n+%\}'],'once','tokens');
if ~isempty(tokens)
   text = tokens{1};
end

end
