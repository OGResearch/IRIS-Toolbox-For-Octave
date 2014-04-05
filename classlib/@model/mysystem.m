function [Syst,NanDerv,Derv] = mysystem(This,IAlt,Opt)
% mysystem [Not a public function] Update system matrices.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Opt.linear
% Opt.select
% Opt.eqtn
% Opt.symbolic

%--------------------------------------------------------------------------

% Select only the equations in which at least one parameter or steady state
% has changed since the last differentiation.
eqSelect = myaffectedeqtn(This,IAlt,Opt);

if strcmpi(Opt.eqtn,'all')
    eqSelect = eqSelect & This.eqtntype <= 2;
elseif strcmpi(Opt.eqtn,'measurement')
    eqSelect = eqSelect & This.eqtntype == 1;
elseif strcmpi(Opt.eqtn,'transition')
    eqSelect = eqSelect & This.eqtntype == 2;
end

% Evaluate derivatives of equations wrt parameters
%--------------------------------------------------
[Derv,NanDerv] = myderiv(This,eqSelect,IAlt,Opt);

% Set up system matrices from derivatives
%-----------------------------------------
doSystem();

% Update handle to last system.
This.lastSyst.asgn = This.Assign(1,:,IAlt);
This.lastSyst.derv = Derv;
This.lastSyst.syst = Syst;


% Nested functions...


%**************************************************************************


    function doSystem()
        
        nm = sum(This.eqtntype == 1);
        nt = sum(This.eqtntype == 2);
        mix = find(eqSelect(1:nm));
        tix = find(eqSelect(nm+1:end));
        nf = sum(imag(This.systemid{2}) >= 0);
        d2s = This.d2s;
        
        Syst = This.lastSyst.syst;
        
        % Measurement equations
        %------------------------
        % A1 y + B1 xb+ + E1 e + K1 = 0
        Syst.K{1}(mix) = Derv.c(mix);
        Syst.A{1}(mix,d2s.y) = Derv.f(mix,d2s.y_);
        % Measurement equations include only bwl variables; subtract
        % therefore the number of fwl variables from the positions of xp1.
        Syst.B{1}(mix,d2s.xp1-nf) = Derv.f(mix,d2s.xp1_);
        Syst.E{1}(mix,d2s.e) = Derv.f(mix,d2s.e_);
        
        % Transition equations
        %----------------------
        % A2 [xf+;xb+] + B2 [xf;xb] + E2 e + K2 = 0
        Syst.K{2}(tix) = Derv.c(nm+tix);
        Syst.A{2}(tix,d2s.xu1) = Derv.f(nm+tix,d2s.xu1_);
        Syst.A{2}(tix,d2s.xp1) = Derv.f(nm+tix,d2s.xp1_);
        Syst.B{2}(tix,d2s.xu) = Derv.f(nm+tix,d2s.xu_);
        Syst.B{2}(tix,d2s.xp) = Derv.f(nm+tix,d2s.xp_);
        Syst.E{2}(tix,d2s.e) = Derv.f(nm+tix,d2s.e_);
        
        % Add dynamic identity matrices
        %-------------------------------
        Syst.A{2}(nt+1:end,:) = d2s.ident1;
        Syst.B{2}(nt+1:end,:) = d2s.ident;
        
        % Effect of non-linear equations
        %--------------------------------
        Syst.N{1} = [];
        Syst.N{2}(tix,:) = Derv.n(nm+tix,:);
        
    end % doSystem()


end