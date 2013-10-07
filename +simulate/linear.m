function S = linear(S,NPer,Opt)
% linear  [Not a public function] Linear simulation.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isequal(NPer,Inf)
    NPer = size(S.e,2);
end

S.lastexog = utils.findlast([S.yAnchors;S.xAnchors]);

if S.lastexog == 0
    
    % Plain simulation
    %------------------
    [S.y,S.w] = simulate.plainlinear( ...
        S,S.a0,S.e,NPer,Opt.deviation,S.Y,S.u);
    
else
    
    % Simulation with exogenised variables
    %--------------------------------------
    % Position of last anticipated and unanticipated endogenised shock.
    S.lastendoga = utils.findlast(S.eaanchors);
    S.lastendogu = utils.findlast(S.euanchors);
    % Exogenised simulation.
    % Plain simulation first.
    [S.y,S.w] = simulate.plainlinear( ...
        S,S.a0,S.e,S.lastexog,Opt.deviation,S.Y,S.u);
    % Compute multiplier matrices in the first round only. No
    % need to re-calculate the matrices in the second and further
    % rounds of non-linear simulations.
    if S.count == 0
        S.M = [ ...
            simulate.multipliers(S,true), ...
            simulate.multipliers(S,false), ...
            ];
    end
    
    % Back out add-factors to shocks.
    S = simulate.exogenise(S);
    if Opt.anticipate
        S.addeu = 1i*S.addeu;
    else
        S.addea = 1i*S.addea;
    end
    S.e(:,1:S.lastendogu) = S.e(:,1:S.lastendogu) + S.addeu;
    S.e(:,1:S.lastendoga) = S.e(:,1:S.lastendoga) + S.addea;
    
    % Re-simulate with shocks added.
    [S.y,S.w] = simulate.plainlinear( ...
        S,S.a0,S.e,NPer,Opt.deviation,S.Y,S.u);
    
end

end