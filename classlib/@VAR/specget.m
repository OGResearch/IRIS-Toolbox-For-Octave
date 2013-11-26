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
        if isequal(Query(end),'*')
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
    case {'omega','omg'}
        X = This.Omega;
    case {'cov'}
        X = This.Omega;
    case {'sgm','sigma','covp','covparameters'}
        X = This.Sigma;
    case 'aic'
        X = This.aic;
    case 'sbc'
        X = This.sbc;
    case {'nfree','nhyper'}
        X = This.nhyper;
    case {'order','p'}
        X = p;
    case {'cumlong','cumlongrun'}
        C = sum(poly.var2poly(This.A),3);
        X = nan(ny,ny,nAlt);
        for iAlt = 1 : nAlt
            if rank(C(:,:,1,iAlt)) == ny
                X(:,:,iAlt) = inv(C(:,:,1,iAlt));
            else
                X(:,:,iAlt) = pinv(C(:,:,1,iAlt));
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
        X = [This.Zi(:,2:end,:),This.Zi(:,1,:)];
    case 'ny'
        X = size(This.A,1);
    case 'ne'
        X = size(This.Omega,2);
    case 'ni'
        X = size(This.Zi,1);
    otherwise
        Flag = false;
end

end
