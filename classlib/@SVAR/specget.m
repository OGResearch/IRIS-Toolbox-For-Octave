function [X,Flag] = specget(This,Query)
% specget  [Not a public function] Implement GET method for SVAR objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(This.A,1);
nAlt = size(This.A,3);

X = []; %#ok<NASGU>
Flag = true;

switch Query
    case 'b'
        X = This.B;
    case {'omg','omega','cove','covresiduals'}
        X = eye(ny);
        X = X(:,:,nAlt);
        for ialt = 1 : nAlt
            X(:,:,ialt) = X(:,:,ialt) * This.std(ialt) .^ 2;
        end
    case 'std'
        X = This.std;
    case {'a','a*'}
        if all(size(This.A) == 0)
            X = [];
        else
            X = poly.var2poly(This.A);
        end
        if isequal(Query,'a*')
            X = -X(:,:,2:end,:);
        end
    case {'cumlong','cumlongrun'}
        C = sum(poly.var2poly(This.A),3);
        X = nan(ny,ny,nAlt);
        for ialt = 1 : nAlt
            if rank(C(:,:,1,ialt)) == ny
                X(:,:,ialt) = C(:,:,1,ialt)\This.B(:,:,ialt);
            else
                X(:,:,ialt) = pinv(C(:,:,1,ialt))*This.B(:,:,ialt);
            end
        end
    case 'method'
        C = This.method;
    otherwise
        [X,Flag] = specget@VAR(This,Query);
end

end
