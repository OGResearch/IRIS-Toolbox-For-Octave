function dispuserdata_4oct(This)
% dispuserdata  [Not a public function] Display userdata.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.
keyboard
%--------------------------------------------------------------------------

if ~isempty(This.userdata)
    tmpSize = sprintf('%gx',size(This.userdata));
    tmpSize(end) = '';
    msg = sprintf('[%s %s]',tmpSize,class(This.userdata));
else
    msg = 'empty';
end

fprintf('\tuser data: %s\n',msg);

end