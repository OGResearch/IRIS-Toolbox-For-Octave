% diff  First difference pseudofunction.
%
% Syntax
% =======
%
%     diff(EXPR)
%     diff(EXPR,K)
%
% Description
% ============
%
% If the input argument `K` is not specified, this pseudofunction expands to
%
%     ((EXPR)-(EXPR{-1}))
%
% If the input argument `K` is specified, it expands to
%
%     ((EXPR)-(EXPR{K}))
%
% The two derived expressions, `EXPR{-1}` and `EXPR{K}`, are
% based on `EXPR`, and have all its time subscripts shifted by --1 or
% by `K` periods, respectively.
%
% Example
% ========
%
% These two lines
%
%     diff(Z)
%     diff(log(X{1})-log(Y{-1}),-2)
%
% will expand to
%
%     ((Z)-(Z{-1}))
%     ((log(X{1})-log(Y{-1}))-(log(X{-1})-log(Y{-3})))
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.
