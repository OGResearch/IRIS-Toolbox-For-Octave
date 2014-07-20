function S = linear(S,NPer,Opt)
% linear  [Not a public function] Linear simulation.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isequal(NPer,Inf)
    NPer = size(S.e,2);
end

S.LastExg = utils.findlast([S.YAnch;S.XAnch]);

if S.LastExg == 0
    
    % Plain simulation
    %------------------
    [S.y,S.w] = simulate.plainlinear( ...
        S,S.a0,S.e,NPer,Opt.deviation,S.Y,S.u);
    
else
    
    % Simulation with exogenised variables
    %--------------------------------------
    % Position of last anticipated and unanticipated endogenised shock.
    S.LastEndgA = utils.findlast(S.EaAnch);
    S.LastEndgU = utils.findlast(S.EuAnch);
    % Exogenised simulation.
    % Plain simulation first.
    [S.y,S.w] = simulate.plainlinear( ...
        S,S.a0,S.e,S.LastExg,Opt.deviation,S.Y,S.u);
    % Compute multiplier matrices in the first round only. No
    % need to re-calculate the matrices in the second and further
    % rounds of non-linear simulations.
    if S.Count == 0
        S.M = [ ...
            simulate.multipliers(S,true), ...
            simulate.multipliers(S,false), ...
            ];
    end
    
    % Back out add-factors to shocks.
    [addEa,addEu] = simulate.exogenise(S);
    if Opt.anticipate
        addEu = 1i*addEu;
    else
        addEa = 1i*addEa;
    end
    S.e(:,1:S.LastEndgU) = S.e(:,1:S.LastEndgU) + addEu;
    S.e(:,1:S.LastEndgA) = S.e(:,1:S.LastEndgA) + addEa;
    
    % Re-simulate with shocks added.
    [S.y,S.w] = simulate.plainlinear( ...
        S,S.a0,S.e,NPer,Opt.deviation,S.Y,S.u);
    
end

end