function H = mychkforpeers(Ax)
% mychkforpeers  [Not a public function] Check for plotyy peers and return the background axes object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

peer = getappdata(Ax,'graphicsPlotyyPeer');

if isempty(peer) || ~isequal(get(Ax,'color'),'none')
    H = Ax;
else
    H = peer;
end

end