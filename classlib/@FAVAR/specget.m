function [X,Flag] = specget(This,Query)
% specget  Implement GET method for FAVAR objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

[X,Flag] = specget@varobj(This,Query);
if Flag
    return
end

X = [];
Flag = true;

nx = size(This.C,2);
p = size(This.A,2)/nx;
nAlt = size(This.C,3);

switch Query
    case 'a'
        if all(size(This.A) == 0)
            X = [];
        else
            X = poly.var2poly(This.A);
        end
    case 'a*'
        X = reshape(This.A,[nx,nx,p,nAlt]);
    case 'b'
        X = This.B;
    case 'c'
        X = This.C;
    case 'omega'
        X = This.Omega;
    case 'sigma'
        X = This.Sigma;
    case 'var'
        X = VAR(This);
    case {'singval','sing','singvalues'}
        X = This.singval;
    case {'ny'}
        X = size(This.C,1);
    case {'nx','nfactor','nfactors'}
        X = size(This.A,1);
    case {'ne'}
        X = size(This.Omega,2);
    case 'nu'
        X = size(This.Sigma,2);
    case 'mean'
        X = This.Mean;
    case 'std'
        X = This.Std;
    otherwise
        Flag = false;
end

end