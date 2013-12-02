function [X,Flag] = specget(This,Query)
% specget  [Not a public function] Implement get method for svarobj class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

X = [];
Flag = true;

switch Query
    case 'b'
        X = This.B;
    case 'cov'
        X = mycovmatrix(This);
    case 'std'
        X = This.std;
    case 'method'
        X = This.method;
    otherwise
        Flag = false;
end

end
