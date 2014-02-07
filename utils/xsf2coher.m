function C = xsf2coher(S,varargin)
% xsf2coher  Convert power spectrum matrices to coherence.
%
% Syntax
% =======
%
%     C = xsf2coher(S)
%
% Input arguments
% ================
%
% * `S` [ numeric ] - Power spectrum matrices computed by the `xsf`
% function.
%
% Output arguments
% =================
%
% * `C` [ numeric ] - Coherence matrices computed from the power spectrum
% matrices.
%
% Options
% ========
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the command
% window.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************
        
    s = size(S);
    n = prod(s(3:end));
    C = zeros(size(S));
    
    % The command `parfor` performs the assignment |C(:,:,i) = ...| much
    % faster than `for` with large matrices.
    parfor i = 1 : n
        Si = S(:,:,i);
        a2 = abs(Si).^2;
        d = diag(Si);
        index = d == 0;
        d(~index) = 1./d(~index);
        d(index) = 0;
        D = diag(d);
        C(:,:,i) = D * a2 * D;
    end

    for i = 1 : size(C,1)
        C(i,i,:) = 1;
    end
    
end