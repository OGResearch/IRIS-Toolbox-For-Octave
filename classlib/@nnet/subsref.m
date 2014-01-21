function X = subsref(This,S)
% subsref  Subscripted reference for nnet objects.
%
% Syntax for retrieving object with subset of parameterisations
% ==============================================================
%
%     M(Inx)
%
% Input arguments
% ================
%
% * `M` [ nnet ] - nnet object.
%
% * `Inx` [ nnet ] - Inx of requested parameterisations.
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

switch S(1).type
    case {'()','{}'}
        X = This ;
        X.Params = This.Params(:,S(1).subs{:}) ;
    case '.'
        X = This.(S(1).subs) ;
end
S(1) = [];
if ~isempty(S)
    X = subsref(X,S);
end

end