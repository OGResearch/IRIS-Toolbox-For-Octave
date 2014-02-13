function This = mynonlineqtn(This)
% mynonlineqtn  [Not a public function] Create function handles for evaluating non-linearised equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Reset non-linear equations to empty strings.
This.eqtnN = cell(size(This.eqtnF));
This.eqtnN(:) = {''};

replacefunc = @doReplace; %#ok<NASGU>
for i = find(This.nonlin)
    eqtn = This.eqtnF{i};
    doBkwComp();
    % Replace variables, shocks, and parameters.
    eqtn = regexprep(eqtn, ...
        'x\(:,(\d+),t([\+\-]\d+)?\)','${replacefunc($1,$2)}');
    % Replace references to steady states.
    eqtn = regexprep(eqtn, ...
        'L\(:,(\d+),t([\+\-]\d+)?\)','L(:,$1)');
    This.eqtnN{i} = eqtn;
end

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
    end % doReplace().

%**************************************************************************
    function doBkwComp()
        % Make sure `eqtn` is a text string, and remove function handle header.
        if isa(eqtn,'function_handle')
            eqtn = func2str(eqtn);
        end
        if eqtn(1) == '@'
            eqtn = regexprep(eqtn,'@\(.*?\)','');
        end
    end % doBkwComp().

end