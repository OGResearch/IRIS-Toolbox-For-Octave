% difflog  First log-difference pseudofunction.
%
% Syntax
% =======
%
%     difflog(EXPR)
%     difflog(EXPR,K)
%
% Description
% ============
%
% If the input argument `K` is not specified, this pseudofunction expands to
%
%     (log(EXPR)-log(EXPR{-1}))
%
% If the input argument `K` is specified, it expands to
%
%     (log(EXPR)-log(EXPR{K}))
%
% The two derived expressions, `EXPR{-1}` and `EXPR{K}`, are
% based on `EXPR`, and have all its time subscripts shifted by --1 or
% by `K` periods, respectively.
%
% Example
% ========
%
% The following two lines of code
%
%     difflog(Z)
%     difflog(X{1}/Y{-1},-2)
%
% will expand to
%
%     (log(Z)-log(Z{-1}))
%     (log(X{1}/Y{-1})-log(X{-1}/Y{-3}))


% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.
