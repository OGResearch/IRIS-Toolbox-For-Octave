function [C,D] = fprintf(This,FName,varargin)
% fprintf  Format SVAR as a model code and write to text file.
%
% Syntax
% =======
%
%     [C,D] = fprintf(S,FName,...)
%
% Input arguments
% ================
%
% * `S` [ SVAR ] - SVAR object that will be printed to a model file.
%
% * `FName` [ char | cellstr ] - Filename, or filename format string, under
% which the model code will be saved.
%
% - Output arguments
%
% * `C` [ cellstr ] - Text string with the model code for each
% parameterisation.
%
% * `D` [ cell ] - Parameter databases for each parameterisation; if
% `'hardParameters='` true, the database will be empty.
%
% Options
% ========
%
% See help on [`sprintf`](SVAR/sprintf) for options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('v',@issvar);
pp.addRequired('fname',@(x) ischar(x) ...
    || (iscellstr(x) && length(This) ==  numel(x)));
pp.parse(This,FName);

%--------------------------------------------------------------------------

[C,D] = sprintf(This,varargin{:});
for iAlt = 1 : length(C)
    if iscellstr(FName)
        thisFName = FName{iAlt};
    else
        thisFName = sprintf(FName,iAlt);
    end
    char2file(C{iAlt},thisFName);
end

end