function H = mychkforpeers(Ax)
% mychkforpeers  [Not a public function] Check for plotyy peers and return the background axes object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if false % ##### MOSW
    peer = getappdata(Ax,'graphicsPlotyyPeer');
else
    peer = get(Ax,'__plotyy_axes__'); %#ok<UNRCH>
    peer = peer(peer ~= Ax);
end

if isempty(peer) || ~isequal(get(Ax,'color'),'none')
    H = Ax;
else
    H = peer;
end

end