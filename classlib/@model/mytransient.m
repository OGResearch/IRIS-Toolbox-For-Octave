function This = mytransient(This)
% mytransient  [Not a public function] Recreate transient properties in model object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

flNameType = floor(This.nametype);

% Reset handle object to last system info.
doLastSyst();

% Create function handles to nonlinear equations.
doNonlinEqtn();


% Nested functions...


%**************************************************************************


    function doLastSyst()

        % Reset lastSyst to a new hlastsystobj handle object.
        This.lastSyst = hlastsystobj();
        
        % Parameters and steady states
        %------------------------------
        asgn = nan(1,size(This.name,2));
        
        % Derivatives
        %-------------
        if issparse(This.occur)
            nt = size(This.occur,2)/length(This.name);
        else
            nt = size(This.occur,3);
        end
        nDerv = nt*sum(flNameType <= 3);
        nEqtn12 = sum(This.eqtntype <= 2);
        derv = struct();
        derv.c = zeros(nEqtn12,1);
        derv.f = sparse(zeros(nEqtn12,nDerv));
        tempEye = -eye(nEqtn12);
        derv.n = tempEye(:,This.IxNonlin);
        
        % System matrices
        %-----------------
        % Sizes of system matrices (different from solution matrices).
        ny = sum(flNameType == 1);
        nx = length(This.systemid{2});
        nf = sum(imag(This.systemid{2}) >= 0);
        nb = nx - nf;
        ne = sum(flNameType == 3);
        
        syst = struct();
        syst.K{1} = zeros(ny,1);
        syst.K{2} = zeros(nx,1);
        syst.A{1} = sparse(zeros(ny,ny));
        syst.B{1} = sparse(zeros(ny,nb));
        syst.E{1} = sparse(zeros(ny,ne));
        syst.N{1} = [];
        syst.A{2} = sparse(zeros(nx,nx));
        syst.B{2} = sparse(zeros(nx,nx));
        syst.E{2} = sparse(zeros(nx,ne));
        syst.N{2} = zeros(nx,sum(This.IxNonlin));
        
        This.lastSyst.asgn = asgn;
        This.lastSyst.derv = derv;
        This.lastSyst.syst = syst;
        
    end % doLastSyst()


%**************************************************************************


    function doNonlinEqtn()
        
        % Reset nonlinear equations to empty strings.
        This.eqtnN = cell(size(This.eqtnF));
        This.eqtnN(:) = {''};
        
        % replaceFunc = @doReplace; %#ok<NASGU>
        for ii = find(This.IxNonlin)
            eqtnN = This.eqtnF{ii};
            
            % Convert fuction handle to char.
            doFunc2Char();
            
            % Replace variables, shocks, and parameters.
            ptn = '\<x\(:,(\d+),t(([\+\-]\d+)?)\)';
            if true % ##### MOSW
                replaceFunc = @doReplace; %#ok<NASGU>
                eqtnN = regexprep(eqtnN,ptn,'${replaceFunc($1,$2)}');
            else
                eqtnN = mosw.dregexprep(eqtnN,ptn,'doReplace',[1,2]); %#ok<UNRCH>
            end
            
            % Replace references to steady states, `L(:,15,t+5)` -> `L(15,T+5)`.
            eqtnN = regexprep(eqtnN, ...
                '\<L\(:,(\d+),t(([\+\-]\d+)?)\)','L($1,T$2)');
            
            eqtnN = strtrim(eqtnN);
            if isempty(eqtnN)
                continue
            end
            
            % Convert char to function handle.
            This.eqtnN{ii} = mosw.str2func(['@(y,xx,e,p,t,L,T) ',eqtnN]);
        end
        
        
        
        function C = doReplace(N,Shift)
            N = str2double(N);
            if isempty(Shift)
                Shift = 0;
            else
                Shift = str2double(Shift);
            end
            if flNameType(N) == 1
                % Measurement variables, no lags or leads.
                inx = find(This.solutionid{1} == N);
                C = sprintf('y(%g,t)',inx);
            elseif flNameType(N) == 2
                % Transition variables.
                inx = find(This.solutionid{2} == N+1i*Shift);
                if ~isempty(inx)
                    time = 't';
                else
                    inx = find(This.solutionid{2} == N+1i*(Shift+1));
                    time = 't-1';
                end
                C = sprintf('xx(%g,%s)',inx,time);
            elseif flNameType(N) == 3
                % Shocks, no lags or leads.
                inx = find(This.solutionid{3} == N);
                C = sprintf('e(%g,t)',inx);
            elseif flNameType(N) == 4
                % Parameters.
                offset = sum(flNameType < 4);
                inx = N - offset;
                C = sprintf('p(%g)',inx);
            end
        end % doReplace()
        
        
        function doFunc2Char()
            % Make sure `eqtn` is a text string, and remove function handle header.
            if isfunc(eqtnN)
                eqtnN = func2str(eqtnN);
            end
            eqtnN = strtrim(eqtnN);
            if eqtnN(1) == '@'
                eqtnN = regexprep(eqtnN,'@\(.*?\)','');
            end
            eqtnN = strrep(eqtnN,' ','');
        end % doFunc2Char
        
        
    end % doNonlinEqtn()


end
