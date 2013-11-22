function [X,Flag] = specget(This,Query)
% specget  [Not a public function] Implement GET method for VAR objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

[X,Flag] = specget@varobj(This,Query);
if Flag
    return
end

X = [];
Flag = true;

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

switch lower(Query)
    case {'a','a*'}
        if all(size(This.A) == 0)
            X = [];
        else
            X = poly.var2poly(This.A);
        end
        if isequal(lower(Query),'a*')
            X = -X(:,:,2:end,:);
        end
    case 'g'
        X = This.G;
    case 't'
        X = This.T;
    case 'u'
        X = This.U;
    case {'const','c','k'}
        X = This.K;
    case {'sgm','sigma','covp','covparameters'}
        X = This.Sigma;
    case 'aic'
        X = This.aic;
    case 'sbc'
        X = This.sbc;
    case 'nhyper'
        X = This.nhyper;
    case {'order','p'}
        X = p;
    case {'cumlong','cumlongrun'}
        C = sum(poly.var2poly(This.A),3);
        X = nan(ny,ny,nAlt);
        for ialt = 1 : nAlt
            if rank(C(:,:,1,ialt)) == ny
                X(:,:,ialt) = inv(C(:,:,1,alt));
            else
                X(:,:,ialt) = pinv(C(:,:,1,ialt));
            end
        end
    case {'constraints','restrictions','constraint','restrict'}
        X = This.Rr;
    case {'inames','ilist'}
        X = This.inames;
    case {'ieqtn'}
        X = This.ieqtn;
    case {'zi'}
        % The constant term comes first in Zi, but comes last in user
        % inputs/outputs.
        X = [This.Zi(:,2:end),This.Zi(:,1)];
    case 'ny'
        X = size(This.A,1);
    case 'ne'
        X = size(This.Omega,2);
    otherwise
        Flag = false;
end

end
