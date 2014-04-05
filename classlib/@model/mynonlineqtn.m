function This = mynonlineqtn(This)
% mynonlineqtn  [Not a public function] Create function handles for evaluating nonlinear equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Reset nonlinear equations to empty strings.
This.eqtnN = cell(size(This.eqtnF));
This.eqtnN(:) = {''};

replacefunc = @doReplace; %#ok<NASGU>
for i = find(This.nonlin)
    eqtn = This.eqtnF{i};
    
    % Convert fuction handle to char.
    doFunc2Char();
    
    % Replace variables, shocks, and parameters.
    eqtn = regexprep(eqtn, ...
        'x\(:,(\d+),t([\+\-]\d+)?\)','${replacefunc($1,$2)}');
    % Replace references to steady states.
    eqtn = regexprep(eqtn, ...
        'L\(:,(\d+),t([\+\-]\d+)?\)','L(:,$1)');
    
    eqtn = strtrim(eqtn);
    if isempty(eqtn)
        continue
    end
    
    % Convert char to function handle.
    eqtn = str2func(['@(y,xx,e,p,t,L) ',eqtn]);
    
    This.eqtnN{i} = eqtn;      
end


% Nested functions...


%**************************************************************************

    
    function C = doReplace(N,Shift)
        N = str2double(N);
        if isempty(Shift)
            Shift = 0;
        else
            Shift = str2double(Shift);
        end
        if This.nametype(N) == 1
            % Measurement variables, no lags or leads.
            inx = find(This.solutionid{1} == N);
            C = sprintf('y(%g,t)',inx);
        elseif This.nametype(N) == 2
            % Transition variables.
            inx = find(This.solutionid{2} == N+1i*Shift);
            if ~isempty(inx)
                time = 't';
            else
                inx = find(This.solutionid{2} == N+1i*(Shift+1));
                time = 't-1';
            end
            C = sprintf('xx(%g,%s)',inx,time);
        elseif This.nametype(N) == 3
            % Shocks, no lags or leads.
            inx = find(This.solutionid{3} == N);
            C = sprintf('e(%g,t)',inx);
        elseif This.nametype(N) == 4
            % Parameters.
            offset = sum(This.nametype < 4);
            inx = N - offset;
            C = sprintf('p(%g)',inx);
        end
    end % doReplace()


%**************************************************************************

    
    function doFunc2Char()
        % Make sure `eqtn` is a text string, and remove function handle header.
        if isa(eqtn,'function_handle')
            eqtn = char(eqtn);
        end
        eqtn = strtrim(eqtn);
        if eqtn(1) == '@'
            eqtn = regexprep(eqtn,'@\(.*?\)','');
        end
    end % doFunc2Char()


end