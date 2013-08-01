function [x,flag] = specget(this,query)
% SPECGET  [Not a public function] Implement GET method for sstate objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

x = [];
flag = true;

switch query
    case {'nblock','nblocks'}
        x = numel(this.type);
    case {'label','labels'}
        x = this.label;
    otherwise
        flag = false;
end
        
end
