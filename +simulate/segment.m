function S = segment(S,Opt)
% segment  [Not a public function] Non-linear simulation of one segment.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

realexp = @(x) real(exp(x));
nx = size(S.T,1);
nb = size(S.T,2);
nf = nx - nb;
ne = size(S.e,1);
nEqtn = length(S.eqtn);
L = S.L;

S.histMinDiscrep = Inf;
S.histMinAddFactor = Inf;
S.histMinU = [];
S.histMinCount = NaN;

while true
    S = simulate.linear(S,S.NPerNonlin,Opt);
    doDiscrepancy();

    if S.maxDiscrep < S.histMinDiscrep
        S.histMinDiscrep = S.maxDiscrep;
        S.histMinAddFactor = S.maxAddFactor;
        S.histMinU = S.u;
        S.histMinCount = S.Count;
    end
    
    % Report discrepancies in this iteration if requested or if
    % this is the final iteration.
    if Opt.display > 0 && mod(S.Count,Opt.display) == 0
        doReport();
    end
    
    if ~isfinite(S.maxDiscrep)
        S.stop = -2;
    elseif S.maxDiscrep <= Opt.tolerance
        S.stop = 1;
    elseif S.Count >= Opt.maxiter;
        S.stop = -1;
    end
    
    if S.stop ~= 0
        if S.maxDiscrep > S.histMinDiscrep
            S.u = S.histMinU;
            S = simulate.linear(S,S.NPerNonlin,Opt);
            if Opt.display > 0
                doReportReverse();
                doDiscrepancy();
            end
        end
        if Opt.display > 0
            doReport();
            fprintf('\n');
        end
        break
    end
    
    % Update and lambda control
    %---------------------------
    if S.maxDiscrep < Opt.upperbound*S.histMinDiscrep %...
            %|| S.maxAddFactor < upperBound*S.histMinAddFactor
        addU = S.discrep;
        if ~Opt.fillout
            addU(abs(addU) <= Opt.tolerance) = 0;
        end
        addU = S.lambda .* addU;
        S.u = S.u - addU;
    else
        % If the current discrepancy is `upperBound` times the historical minimum
        % (or more), reverse the process to the historical minimum, and reduce
        % `lambda`.
        S.u = S.histMinU;
        S.lambda = S.lambda * Opt.reducelambda;
        if Opt.display > 0
            doReportReverse();
            doReportLambdaReduction();
        end
    end
    S.Count = S.Count + 1;
end

% Failed to converge
%--------------------
if S.stop < 0
    if Opt.error
        % @@@@@ MOSW
        msgFunc = @(varargin) utils.error(varargin{:});
    else
        % @@@@@ MOSW
        msgFunc = @(varargin) utils.warning(varargin{:});
    end

    switch S.stop
        case -1
            msgFunc('model', ...
                ['Non-linear simulation #%g, segment %s, ', ...
                'reached the max number of iterations ', ...
                'without achieving convergence.'], ...
                S.iLoop,strtrim(S.segmentString));
        case -2
            msgFunc('model', ...
                ['Non-linear simulation #%g, segment %s, ', ...
                'crashed at Inf, -Inf, or NaN.'], ...
                S.iLoop,strtrim(S.segmentString));
    end
end


% Nested functions...


%**************************************************************************

    
    function doDiscrepancy()
        range = 1 : S.NPerNonlin; 
        % Set up the vector of [xf;xb] and include initial condition.
        xx = [[nan(nf,1);S.a0],S.w(:,range)];
        xx(nf+1:end,:) = S.U*xx(nf+1:end,:);
        if Opt.deviation && Opt.addsstate
            xx = xx + S.XBar;
        end
        
        % Delogarithmise log-variables.
        xx(S.IxXLog,:) = realexp(xx(S.IxXLog,:));
        
        % Set up the vector of shocks including initial condition.
        e = real(S.e(:,range)) + imag(S.e(:,range));
        e = [zeros(ne,1),e];
        % No measurement variables in the transition equations.
        y = [];
        % Get the current parameter values.
        p = S.Assign(1,S.nametype == 4);
        d = zeros(nEqtn,1+S.NPerNonlin);
        nanInx = false(1,nEqtn);
        errMsg = {};
        evalInx = [false,S.QAnch];
        if any(evalInx)
            tVec = find(evalInx);
            % "Absolute time" within the entire nonlinear simulation for sstate
            % references.
            TVec = -S.MinT + S.First + tVec - 2;
            for j = find(S.IxNonlin)
                try
                    dj = S.eqtnN{j}(y,xx,e,p,tVec,L,TVec);
                    nanInx(j) = any(~isfinite(dj));
                    d(j,evalInx) = dj;
                catch Err
                    errMsg{end+1} = S.eqtn{j}; %#ok<AGROW>
                    errMsg{end+1} = Err.message; %#ok<AGROW>
                end
            end
        end
        if ~isempty(errMsg)
            utils.error('simulate:segment', ...
                ['Error evaluating this nonlinear equation: ''%s''.\n ', ...
                '\tUncle says: %s'], ...
                errMsg{:});
        end
        if any(nanInx)
            utils.error('simulate:segment', ...
                ['This nonlinear equation produces ', ...
                'NaN or Inf: ''%s''.'], ...
                S.eqtn{nanInx});
        end
        S.discrep = d(S.IxNonlin,2:end);
        % Maximum discrepancy and max addfactor.
        S.maxDiscrep2 = max(abs(S.discrep),[],2);
        S.maxDiscrep = max(S.maxDiscrep2);
        S.maxAddFactor2 = max(abs(S.u),[],2);
        S.maxAddFactor = max(S.maxAddFactor2);
    end % doDiscrepancy()


%**************************************************************************
 
    
    function doReport()
        % doReport  Report one nonlin simulation iteration.
        maxDiscrepEqtn = ...
            findnaninf(S.maxDiscrep2,S.maxDiscrep,1,'first');
        maxAddFactorEqtn = ....
            findnaninf(S.maxAddFactor2,S.maxAddFactor,1,'first');
        if S.Count == 0 && S.stop == 0
            % This is the very first report line printed. Print the
            % header first.
            fprintf(...
                '%16s %6.6s %12.12s %-20.20s %7.7s %12.12s %-20.20s\n',...
                'Segment#NPer','Iter','Max.discrep','Equation','Lambda', ...
                'Max.addfact','Equation' ...
                );
        end
        count = sprintf(' %5g',S.Count);
        if S.stop ~= 0
            count = strrep(count,' ','=');
        end
        lambda = sprintf('%7g',S.lambda);
        maxDiscrep = sprintf('%12g',S.maxDiscrep);
        maxDiscrepLabel = S.label{maxDiscrepEqtn};
        maxDiscrepLabel = strfun.ellipsis(maxDiscrepLabel,20);
        maxAddFactor = sprintf('%12g',S.maxAddFactor);
        maxAddFactorLabel = S.label{maxAddFactorEqtn};
        maxAddFactorLabel = strfun.ellipsis(maxAddFactorLabel,20);
        % Print current report line.
        fprintf(...
            '%s %s %s %s %s %s %s\n',...
            S.segmentString,count, ...
            maxDiscrep,maxDiscrepLabel,lambda, ...
            maxAddFactor,maxAddFactorLabel ...
            );
    end % doReport()


%**************************************************************************

    
    function doReportReverse()
        fprintf('  Reversing to iteration %g.\n', ...
            S.histMinCount);
    end % doReportReverse()


%**************************************************************************

    
    function doReportLambdaReduction()
        fprintf('  Reducing lambda to %g.\n', ...
            S.lambda);
    end % doReportLambdaReduction()


end
