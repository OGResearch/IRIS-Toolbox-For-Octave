function [X,Flag,Query] = specget(This,Query)
% specget  [Not a public function] Get method for theparser objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

X = [];
Flag = true;

switch Query
    
    case 'file'
        X = This.FName;
        
    otherwise
        Flag = false;
        
end

end
