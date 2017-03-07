function [O,Y0,K0,Y1,G1] = sumofcoeff(Mu,varargin)
% sumofcoeff  Doan et al sum-of-coefficient prior dummy observations for BVARs.
%
% Syntax
% =======
%
%     O = BVAR.sumofcoeff(Mu)
%
% Input arguments
% ================
%
% * `Mu` [ numeric ] - Weight on the dummy observations.
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
% See [the section explaining the weights on prior dummies](BVAR/Contents),
% i.e. the input argument `Mu`.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('Mu',@isnumericscalar);
pp.parse(Mu);

if ~isempty(varargin) && nargout == 1
    utils.warning('BVAR:sumofcoeff', ...
        ['This is an obsolete syntax to call BVAR.litterman(). ', ...
        'See documentation for valid syntax.']);
end

%--------------------------------------------------------------------------

This = BVAR.bvarobj();
This.name = 'sumofcoeff';
if false % ##### MOSW
    This.y0 = @y0;
    This.k0 = @k0;
    This.y1 = @y1;
    This.g1 = @g1;
else
    This.y0 = @(Ny,~,~,~)  y0_oct(Ny,Mu);
    This.k0 = @(Ny,~,~,Nk) k0(Ny,[],[],Nk);
    This.y1 = @(Ny,P,~,~)  y1_oct(Ny,P,Mu);
    This.g1 = @(~,~,Ng,~)  g1([],[],Ng,[]);
end

if ~isempty(varargin) && nargout > 1
    [Y0,K0,Y1,G1] = BVAR.mydummymat(This,varargin{:});
end


% Nested functions...


%**************************************************************************

    
    function Y0 = y0(Ny,~,~,~)
        Y0 = eye(Ny)*Mu;
    end % y0()


%**************************************************************************


    function K0 = k0(Ny,~,~,Nk)
        K0 = zeros(Nk,Ny);
    end % k0()


%**************************************************************************
    

    function Y1 = y1(Ny,P,~,~)
        Y1 = repmat(Mu*eye(Ny),[P,1]);
    end % y1()


%**************************************************************************

    
    function G1 = g1(~,~,Ng,~)
        G1 = zeros(Ng,Ny);
    end % g1()


%**************************************************************************

    
    function Y0 = y0_oct(Ny,Mu)
        Y0 = eye(Ny)*Mu;
    end % y0_oct()


%**************************************************************************
    

    function Y1 = y1_oct(Ny,P,Mu)
        Y1 = repmat(Mu*eye(Ny),[P,1]);
    end % y1_oct()



end
