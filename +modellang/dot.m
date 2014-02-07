% dot  Gross rate of growth pseudofunction.
%
% Syntax
% =======
%
%     dot(EXPR)
%     dot(EXPR,K)
%
% Description
% ============
%
% If the input argument `k` is not specified, this pseudofunction expands
% to
%
%     ((expression)/(expression{-1}))
%
% If the input argument `k` is specified, it expands to
%
%     ((expression)/(expression{k}))
%
% The two derived expressions, `expression{-1}` and `expression{k}`, are
% based on `expression`, and have all its time subscripts shifted by --1 or
% by `k` periods, respectively.
%
% Example
% ========
%
% The following two lines
%
%     dot(Z)
%     dot(X+Y,-2)
%
% will expand to
%
%     ((Z)/(Z{-1}))
%     ((X+Y)/(X{-2}+Y{-2}))
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.
