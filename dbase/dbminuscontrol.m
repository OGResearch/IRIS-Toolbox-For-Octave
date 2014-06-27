function [DMC,C] = dbminuscontrol(This,D,C)
% dbminuscontrol  Create simulation-minus-control database.
%
% Syntax
% =======
%
%    [D,C] = dbminuscontrol(M,D)
%    [D,C] = dbminuscontrol(M,D,C)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object on which the databases `D` and `C` are
% based.
%
% * `D` [ struct ] - Simulation database.
%
% * `C` [ struct ] - Control database; if the input argument `C` is not
% specified, the steady-state database of the model `M` is used for the
% control database.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Simulation-minus-control database, in which all
% log-variables are `d.x/c.x`, and all other variables are `d.x-c.x`.
%
% * `C` [ struct ] - Control database.
%
% Description
% ============
%
% Example
% ========
%
% We run a shock simulation in full levels using a steady-state (or
% balanced-growth-path) database as input, and then compute the deviations
% from the steady state.
%
%     d = sstatedb(m,1:40);
%     ... % Set up a shock or shocks here.
%     s = simulate(m,d,1:40);
%     s = dbextend(d,s);
%     s = dbminuscontrol(m,s,d);
%
% Note that this is equivalent to running
%
%     d = zerodb(m,1:40);
%     ... % Set up a shock or shocks here.
%     s = simulate(m,d,1:40,'deviation',true);
%     s = dbextend(d,s);
%

% -The IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

try
    C; 
catch
    C = [];
end

pp = inputParser();
pp.addRequired('M',@(x) mosw.isa(x,'modelobj'));
pp.addRequired('D',@isstruct);
pp.addRequired('C',@(x) isstruct(x) || isempty(x));
pp.parse(This,D,C);


%--------------------------------------------------------------------------

list = [get(This,'ylist'),get(This,'xlist'),get(This,'elist')];
isLog = get(This,'log');

if isempty(C)
    range = dbrange(D,list, ...
        'startdate=','maxrange','enddate=','maxrange');
    C = sstatedb(This,range);
end

DMC = D;
remove = false(size(list));
for i = 1 : length(list)
    if isfield(D,list{i}) && isfield(C,list{i})
        if isLog.(list{i})
            func = @rdivide;
        else
            func = @minus;
        end
        try
            DMC.(list{i}) = bsxfun( ...
                func, ...
                real(DMC.(list{i})), ...
                real(C.(list{i})) ...
                );
        catch %#ok<CTCH>
            remove(i) = true;
        end
    else
        remove(i) = true;
    end
end

if any(remove)
    DMC = rmfield(DMC,list(remove));
end

end