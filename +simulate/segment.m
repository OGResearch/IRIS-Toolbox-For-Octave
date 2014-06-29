function S = segment(S,Opt)
% segment  [Not a public function] Non-linear simulation of one segment.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

nx = size(S.T,1);
nb = size(S.T,2);
nf = nx - nb;
ne = size(S.e,1);
nEqtn = length(S.eqtn);

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
        messageFunc = @utils.error;
    else
        messageFunc = @utils.warning;
    end

    switch S.stop
        case -1
            messageFunc('model', ...
                ['Non-linear simulation #%g, segment %s, ', ...
                'reached the max number of iterations ', ...
                'without achieving convergence.'], ...
                S.iLoop,strtrim(S.segmentString));
        case -2
            messageFunc('model', ...
                ['Non-linear simulation #%g, segment %s, ', ...
                'crashed at Inf, -Inf, or NaN.'], ...
                S.iLoop,strtrim(S.segmentString));
    end
end


% Nested functions...


%**************************************************************************

    
    function doDiscrepancy()
        tt = 1 : S.NPerNonlin;
        LL = S.TrendArray; 
        % Set up the vector of [xf;xb] and include initial condition.
        xx = [[nan(nf,1);S.a0],S.w(:,tt)];
        xx(nf+1:end,:) = S.U*xx(nf+1:end,:);
        if Opt.deviation && Opt.addsstate
            xx = xx + S.XBar;
        end
        
        % Delogarithmise log-plus and log-minus variables.
        xx(S.XLogSign == 1,:) = exp(xx(S.XLogSign == 1,:));
        xx(S.XLogSign == -1,:) = -exp(xx(S.XLogSign == -1,:));
        
        % Set up the vector of shocks including initial condition.
        ee = real(S.e(:,tt)) + imag(S.e(:,tt));
        ee = [zeros(ne,1),ee];
        % No measurement variables in the transition equations.
        yy = [];
        % Get the current parameter values.
        pp = S.Assign(1,S.nametype == 4);
        d = zeros(nEqtn,1+S.NPerNonlin);
        nanInx = false(1,nEqtn);
        errorMsg = {};
        for j = find(S.nonlin)   
            evalInx = [false,S.QAnch(j,:)];
            if ~any(evalInx)
                continue
            end
            try
                dj = S.eqtnN{j}(yy,xx,ee,pp,find(evalInx),LL); %#ok<FNDSB>
                nanInx(j) = any(~isfinite(dj));
                d(j,evalInx) = dj;
            catch Error
                errorMsg{end+1} = S.eqtn{j}; %#ok<AGROW>
                errorMsg{end+1} = Error.message; %#ok<AGROW>
            end
        end
        if ~isempty(errorMsg)
            utils.error('model', ...
                ['Error evaluating this non-linearised equation: ''%s''.\n ', ...
                '\tMatlab says: %s'], ...
                errorMsg{:});
        end
        if any(nanInx)
            utils.error('model', ...
                ['This non-linearised equation produces ', ...
                'NaN or Inf: ''%s''.'], ...
                S.eqtn{nanInx});
        end
        S.discrep = d(S.nonlin,2:end);
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