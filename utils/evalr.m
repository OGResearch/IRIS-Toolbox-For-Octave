function evalr(Expr,Range)
% evalr  Evaluate tseries expression recursively.
%
% Syntax
% =======
%
%     evalr(Expr,Range)
%
% Input arguments
% ================
%
% * `Eqtn` [ char ] - Equation that will be evaluated recursively ; the
% expression must be `'LHS_Name = RHS_Expr'` where `LHS_Name` is the name
% of the LHS variable (which must be a tseries object), and `RHS_Expr` is
% the RHS expression that will be evaluated for each period in `Range`, and
% whose result will be immediately assigned to the variables named
% `LHS_Name`.
%
% * `Range` [ numeric ] - Date range or vector of dates over which the
% expression will be evaluated.
%
% Description
% ============
%
% Example
% ========
%
% The following commands create an autoregressive process with random
% shocks:
%
%     x = tseries(qq(2000,1):qq(2015,4),0);
%     e = tseries(qq(2000,1):qq(2015,4),@randn);
%     evalr('x = 0.8*x{-1} + e',qq(2000,2):qq(2015,4));
%

%--------------------------------------------------------------------------

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

Range = Range(:).';

pos = strfind(Expr,'=');
pos = pos(1);
Name = strtrim(Expr(1:pos-1));
Expr = strtrim(Expr(pos+1:end));

X = evalin('caller',Name);
if ~istseries(X)
    utils.error('utils:evalr', ...
        'LHS variables in evalr( ) must be tseries object.');
elseif ~isempty(X) && any(freq(X) ~= datfreq(Range))
    utils.error('utils:evalr', ...
        ['LHS tseries object and all input dates must have ', ...
        'the same date frequency.']);
end    

Expr = regexprep(Expr,'(?<=\w)\{(.*?)\}','($Time$+($1))');
    
for t = Range
    [y,p,f] = dat2ypf(t);
    Expr1 = strrep(Expr,'$Time$',sprintf('datcode(%g,%g,%g)',f,y,p));
    try
        value = evalin('caller',Expr1);
    catch
        utils.error('utils:evalr', ...
            'Error evaluating expression ''%s''.', ...
            Expr);
    end
    
    if istseries(value)
        value = value(t);
    end
    if (isnumeric(value) || islogical(value)) ...
            && size(value,1) == 1
        X = evalin('caller',Name);
        if length(value) > 1 && isempty(X.data)
            s = size(X.data);
            X.data = zeros([0,s(2:end)]);
        end
        X(t) = value;
        assignin('caller',Name,X);
    else
        utils.error('utils:evalr', ...
            'Expression ''%s'' evaluates to invalid value or size.', ...
            Expr);
    end
    
end

end
