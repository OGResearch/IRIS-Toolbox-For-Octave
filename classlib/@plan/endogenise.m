function This = endogenise(This,List,Dates,Weight)
% endogenise  Endogenise shocks or re-endogenise variables at the specified dates.
%
% Syntax
% =======
%
%     P = endogenise(P,List,Dates)
%     P = endogenise(P,Dates,List)
%     P = endogenise(P,List,Dates,Sigma)
%     P = endogenise(P,Dates,List,Sigma)
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
% * `List` [ cellstr | char ] - List of shocks that will be endogenised, or
% list of variables that will be re-endogenise.
%
% * `Dates` [ numeric ] - Dates at which the shocks or variables will be
% endogenised.
%
% * `Sigma` [ numeric ] - Select the anticipation mode, and assign a weight
% to the shock in the case of underdetermined simulation plans; if omitted,
% `Sigma = 1`.
%
% Output arguments
% =================
%
% * `P` [ plan ] - Simulation plan with new information on endogenised
% shocks included.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

try
    Weight; 
catch 
    Weight = 1;
end

if isnumeric(List) && (ischar(Dates) || iscellstr(Dates))
    [List,Dates] = deal(Dates,List);
end

% Parse required input arguments.
pp = inputParser();
pp.addRequired('P',@is.plan);
pp.addRequired('List',@(x) ischar(x) || iscellstr(x));
pp.addRequired('Dates',@isnumeric);
pp.addRequired('Weight', ...
    @(x) is.numericscalar(x) && ~(real(x) ~=0 && imag(x) ~=0) ...
    && real(x) >= 0 && imag(x) >= 0);
pp.parse(This,List,Dates,Weight);

% Convert char list to cell of str.
if ischar(List)
    List = regexp(List,'[A-Za-z]\w*','match');
end

if isempty(List)
    return
end

%--------------------------------------------------------------------------

[Dates,outOfRange] = mydateindex(This,Dates);

if ~isempty(outOfRange)
    % Report invalid dates.
    utils.error('plan', ...
        'Dates out of simulation plan range: %s.', ...
        dat2charlist(outOfRange));
end

nList = numel(List);
valid = true(1,nList);

for i = 1 : nList
    % Try to endogenise a shock.
    inx = strcmp(This.nList,List{i});
    if any(inx)
        if Weight == 0
            % Re-exogenise the shock again.
            This.nAnchorsReal(inx,Dates) = false;
            This.nAnchorsImag(inx,Dates) = false;
            This.nWeightsReal(inx,Dates) = 0;
            This.nWeightsImag(inx,Dates) = 0;            
        elseif real(Weight) > 0
            % Real endogenised shocks.
            This.nAnchorsReal(inx,Dates) = true;
            This.nWeightsReal(inx,Dates) = Weight;
        elseif imag(Weight) > 0
            % Imaginary endogenised shocks.
            This.nAnchorsImag(inx,Dates) = true;
            This.nWeightsImag(inx,Dates) = Weight;
        end
    else
        % Try to re-endogenise an endogenous variable.
        inx = strcmp(This.xList,List{i});
        if any(inx)
            This.xAnchors(inx,Dates) = false;
        else
            % Neither worked.
            valid(i) = false;
        end
    end
end

% Report invalid names.
if any(~valid)
    utils.error('plan', ...
        'Cannot endogenise this name: ''%s''.', ...
        List{~valid});
end

end