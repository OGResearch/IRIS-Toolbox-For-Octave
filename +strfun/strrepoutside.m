function str = strrepoutside(str,find,replace,varargin)
% strrepoutside  Replace substring outside brackets.
%
% Syntax
% =======
%
%     s = strfun.strrepoutside(s,find,replace,brackets,brackets,...)
%
% Input arguments
% ================
%
% * `s` [ char | cellstr ] - Original text string or cellstr.
%
% * `find` [ char | cellstr ] - Text string whose occurences will be
% replaced with `replace`.
%
% * `replace` [ char | cellstr ] - Text string that will replace `find`.
%
% * `brackets` [ char ] - Text string with the opening and closing
% bracket; the string replacement will only be made outside all of the
% specified brackets.
%
% Output arguments
% =================
%
% * `s` [ char | cellstr ] - Modified text string.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Handle cellstr on input.
nstr = numel(str);
if iscellstr(str)
    for i = 1 : nstr
        str{i} = strfun.strrepoutside(str{i},find,replace,varargin{:});
    end
    return
end

%**************************************************************************

% nfind = numel(find);
nbrk = numel(varargin);
brks = zeros([nbrk,nstr]);
for i = 1 : nbrk
    brks(i,strfind(str,varargin{i}(1))) = 1;
    brks(i,strfind(str,varargin{i}(2))) = -1;
end
outsideIndex = all(cumsum(brks,2) == 0,1);
insideContent = str(~outsideIndex);
str(~outsideIndex) = char(0);
str = strrep(str,find,replace);
str(~outsideIndex) = insideContent;

end
