function [This,Y0,K0,Y1,G1] = covmat(C,Repeat,varargin)
% covmat  Covariance matrix prior dummy observations for BVARs.
%
% Syntax
% =======
%
%     O = BVAR.covmat(C,Rep)
%
% Input arguments
% ================
%
% * `C` [ numeric ] - Prior covariance matrix of residuals; if `C` is a
% vector it will be converted to a diagonal matrix.
%
% * `Rep` [ numeric ] - The number of times the dummy observations will
% be repeated.
%
% Output arguments
% =================
%
% * `O` [ bvarobj ] - BVAR object that can be passed into the
% [`VAR/estimate`](VAR/estimate) function.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Parse input arguments.
pp = inputParser();
pp.addRequired('Cov',@(x) isnumeric(x) && ismatrix(x));
pp.addRequired('Rep',@(x) isintscalar(x) && x > 0);
pp.parse(C,Repeat);


%--------------------------------------------------------------------------

if isvector(C)
    C = diag(sqrt(C));
else
    C = chol(C).';
end

This = BVAR.bvarobj();
This.name = 'covmat';
if false % ##### MOSW
    This.y0 = @y0;
    This.k0 = @k0;
    This.y1 = @y1;
    This.g1 = @g1;
else
    This.y0 = @(~,~,~,~)   y0_oct(C,Repeat);
    This.k0 = @(Ny,~,~,~)  k0_oct(Ny,Repeat);
    This.y1 = @(Ny,P,~,~)  y1_oct(Ny,P,Repeat);
    This.g1 = @(Ny,~,Ng,~) g1_oct(Ny,Ng,Repeat);
end

if ~isempty(varargin) && nargout > 1
    [Y0,K0,Y1,G1] = BVAR.mydummymat(This,varargin{:});
end


% Nested functions...


%**************************************************************************

    
    function Y0 = y0(~,~,~,~)
        Y0 = C;
        if Repeat > 1
            Y0 = repmat(Y0,1,Repeat);
        end
    end % y0()


%**************************************************************************

    
    function K0 = k0(Ny,~,~,~)
        K0 = zeros(1,Ny);
        if Repeat > 1
            K0 = repmat(K0,1,Repeat);
        end
    end % k0()


%**************************************************************************

    
    function Y1 = y1(Ny,P,~,~)
        Y1 = zeros(Ny*P,Ny);
        if Repeat > 1
            Y1 = repmat(Y1,1,Repeat);
        end
    end % y1()


%**************************************************************************

    
    function G1 = g1(Ny,~,Ng,~)
        G1 = zeros(Ng,Ny);
        if Repeat > 1
            G1 = repmat(G1,1,Repeat);
        end
    end % g1()


%**************************************************************************

    
    function Y0 = y0_oct(C,Repeat)
        Y0 = C;
        if Repeat > 1
            Y0 = repmat(Y0,1,Repeat);
        end
    end % y0_oct()


%**************************************************************************

    
    function K0 = k0_oct(Ny,Repeat)
        K0 = zeros(1,Ny);
        if Repeat > 1
            K0 = repmat(K0,1,Repeat);
        end
    end % k0_oct()


%**************************************************************************

    
    function Y1 = y1_oct(Ny,P,Repeat)
        Y1 = zeros(Ny*P,Ny);
        if Repeat > 1
            Y1 = repmat(Y1,1,Repeat);
        end
    end % y1_oct()


%**************************************************************************

    
    function G1 = g1_oct(Ny,Ng,Repeat)
        G1 = zeros(Ng,Ny);
        if Repeat > 1
            G1 = repmat(G1,1,Repeat);
        end
    end % g1_oct()


end
