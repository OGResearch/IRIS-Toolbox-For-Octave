function Opt = mychksstateopt(This,varargin) %#ok<INUSL>
% mychsstateopt  [Not a public function] Prepare steady-state check options.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if length(varargin) == 1 && isequal(varargin{1},false)
    Opt = false;
    return
end

if length(varargin) == 1 && isequal(varargin{1},true)
    varargin(1) = [];
end

Opt = passvalopt('model.mychksstate',varargin{:});

%--------------------------------------------------------------------------

end