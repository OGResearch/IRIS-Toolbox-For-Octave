function [This,Data,B,Count] = SVAR(V,Data,varargin)
% SVAR  [Not a public function] Identify SVAR from a reduced-form VAR.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    Data; %#ok<VUNUS>
catch
    Data = [];
end

% Parse required input arguments.
pp = inputParser();
pp.addRequired('Data',@(x) isempty(x) || isnumeric(x) || istseries(x) ...
    || isstruct(x));
pp.parse(Data);

opt = passvalopt('SVAR.SVAR',varargin{1:end});

%--------------------------------------------------------------------------

ny = size(V.A,1);
nAlt = size(V.A,3);

% Create an empty SVAR object.
This = SVAR();
This.B = nan(ny,ny,nAlt);
This.Std = nan(1,nAlt);

% Populate properties inherited from superclass VAR.
This = mystruct2obj(This,V);

% Identify the B matrix.
[This,Data,B,Count] = myidentify(This,Data,opt);

if nargin < 2 || nargout < 2 || isempty(Data)
    return
end

% Convert reduced-form residuals to structural shocks.
Data = mystructuralshocks(This,Data,opt);

end
