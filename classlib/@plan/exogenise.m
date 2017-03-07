function This = exogenise(This,List,Dates,Flag)
% exogenise  Exogenise variables or re-exogenise shocks at the specified dates.
%
% Syntax
% =======
%
%     P = exogenise(P,List,Dates)
%     P = exogenise(P,Dates,List)
%     P = exogenise(P,List,Dates,Mode)
%     P = exogenise(P,Dates,List,Mode)
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
% * `List` [ cellstr | char ] - List of variables that will be exogenised,
% or list of shocks that will be re-exogenised.
%
% * `Dates` [ numeric ] - Dates at which the variables will be exogenised.
%
% * `Flag` [ `1` | `1i` ] - Only when re-exogenising shocks: Select the
% anticipation mode in which the shock will be re-exogenised; if omitted,
% `Flag = 1`.
%
% Output arguments
% =================
%
% * `P` [ plan ] - Simulation plan with new information on exogenised
% variables included.
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
    Flag;
catch
    Flag = 1;
end

if isnumeric(List) && (ischar(Dates) || iscellstr(Dates))
    [List,Dates] = deal(Dates,List);
end

% Parse required input arguments.
pp = inputParser();
pp.addRequired('List',@(x) ischar(x) || iscellstr(x));
pp.addRequired('Dates',@isnumeric);
pp.addRequired('Weight', ...
    @(x) isnumericscalar(x) && ~(real(x) ~=0 && imag(x) ~=0) ...
    && real(x) >= 0 && imag(x) >= 0 && x ~= 0);
pp.parse(List,Dates,Flag);

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
    % Try to exogenise an endogenous variable.
    index = strcmp(This.XList,List{i});
    if any(index)
        This.XAnch(index,Dates) = true;
    else
        % Try to re-exogenise a shock.
        index = strcmp(This.NList,List{i});
        if any(index)
            if real(Flag) > 0
                This.NAnchReal(index,Dates) = false;
                This.NWghtReal(index,Dates) = 0;
            elseif imag(Flag) > 0
                This.NAnchImag(index,Dates) = false;
                This.NWghtImag(index,Dates) = 0;
            end
        else
            % Neither worked.
            valid(i) = false;
        end
    end
end

% Report invalid names.
if any(~valid)
    utils.error('plan', ...
        'Cannot exogenise this name: ''%s''.', ...
        List{~valid});
end

end
