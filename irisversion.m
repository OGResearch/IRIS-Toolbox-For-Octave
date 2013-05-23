function [C,N] = irisversion()
% irisversion  Current IRIS version.
%
% Syntax
% =======
%
%     irisversion
%     X = irisversion()
%
% Output arguments
% =================
%
% * `X` [ char ] - String describing the currently installed IRIS version.
%
% Description
% ============
%
% The version string consists of the generation number, followed by a dot
% and the distribution date (yyyymmdd).
%
% The `irisversion` function is equivalent to the following call to
% calling `irisget('version')`.
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% IRIS version is permanently stored in the root Contents.m file, and is
% accessible through the Matlab ver() command. In each session, the version
% is refreshed by the `irisconfig` file.

C = irisconfigmaster('get','version');
if nargout > 1
    N = str2double(C);
end

end