function Flag = isempty(This,varargin)
% isempty  True if system priors object is empty.
%
% Syntax
% =======
%
%     Flag = isempty(S)
%
% Input arguments
% ================
%
% * `S` [ systempriors ] - System priors,
% [`systempriors`](systempriors/Contents), object.
%
% Output arguments
% =================
%
% * `Flag` [ true | false ] - True if the system priors object, `S`, is
% empty, false otherwise.
%
% Description
% ============
%
% Example
% ========

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(varargin)
    Flag = isempty(This.eval);
else
    Flag = isempty(This.systemFunc.(lower(varargin{1})).page);
end

end