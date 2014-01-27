function nowrunning()
% nowrunning  Display a header for the currently executed script.
%
% Syntax
% =======
%
%     nowrunning
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

% Determine the name of the caller.
stack = dbstack('-completenames');
if length(stack) < 2
    return
end
callername = stack(2).file;

% Create header.
mainline = sprintf('Now running <a href="matlab: edit %s">%s</a>', ...
    callername,callername);
dateline = datestr(now());
len = length(regexprep(mainline,'<.*?>',''))+2;
divline = repmat('*',1,len);

% Display header.
strfun.loosespace();
disp(['%',divline]);
disp(['% ',mainline]);
disp(['% ',dateline]);
disp(['%',divline]);
strfun.loosespace();

end