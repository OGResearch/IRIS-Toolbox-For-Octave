function detail(This)
% detail  Display details of system priors object.
%
% Syntax
% =======
%
%     detail(S)
%
% Input arguments
% ================
%
% * `S` [ systempriors ] - System priors,
% [`systempriors`](systempriors/Contents) object.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

nPrior = length(This.eval);
nDigit = 1 + floor(log10(nPrior));
strfun.loosespace();
for i = 1 : nPrior
    if ~isempty(This.priorFunc{i})
        priorFuncName = This.priorFunc{i}([],'name');
        priorMean = This.priorFunc{i}([],'mean');
        priorStd = This.priorFunc{i}([],'std');
        priorDescript = sprintf('Distribution: %s mean=%g std=%g', ...
            priorFuncName,priorMean,priorStd);
    else
        priorDescript = '[]';
    end
    fprintf('\t#%*g  %s\n',nDigit,i,This.userString{i});
    fprintf('\t\t%s\n',priorDescript);
    fprintf('\t\tBounds: lower=%g upper=%g\n', ...
        This.lowerBound(i),This.upperBound(i));
    strfun.loosespace();
end

end
