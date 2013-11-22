function DF = d(Func,K,varargin)
% d  [Not a public function] Compute numerical derivatives of non-analytical or user-defined functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Test if the user function returns derivatives
%
%     func(x,y,z,'diff')
%
% This call to `func` must produce `true`.
%
% Get a user-supplied first derivative by calling the function itself with
% a 'diff' argument. For example,
%
%     func(x,y,z,'diff',3)
%
% expects the first derivative of the function w.r.t. the 3-rd input
% argument.

try
    test = feval(Func,varargin{:},'diff');
    isUserDiff = isequal(test,true);
catch %#ok<CTCH>
    isUserDiff = false;
end

% Capture the user-supplied derivative
%--------------------------------------
nd = length(varargin{K(end)});
if isUserDiff
    status = warning();
    warning('off'); %#ok<WNOFF>
    try
        % User-supplied derivatives.
        DF = feval(Func,varargin{:},'diff',K);
        if ~isnumeric(DF) || length(DF) ~= nd
            DF = NaN;
        end
    catch %#ok<CTCH>
        DF = NaN;
    end
    warning(status);
    if isfinite(DF)
        return
    end
end

% Compute the derivative numerically
%------------------------------------
if length(K) == 1
    % First derivative.
    DF = xxDiffNum(Func,K,varargin{:});
    return
elseif length(K) == 2
    % Second derivative; these are needed in optimal policy models with
    % user-supplied functions.
    y0 = varargin{K(2)};
    hy = abs(eps()^(1/3.5))*max([y0,1]);
    yp = y0 + hy;
    ym = y0 - hy;
    varargin{K(2)} = yp;
    fp = xxDiffNum(Func,K(1),varargin{:});
    varargin{K(2)} = ym;
    fm = xxDiffNum(Func,K(1),varargin{:});
    DF = (fp - fm) / (yp - ym);
end

end


% Subfunctions.


%**************************************************************************


function DF = xxDiffNum(Func,K,varargin)

epsilon = eps()^(1/3.5);
x0 = varargin{K};
hx = abs(epsilon*max(x0,1));
xp = x0 + hx;
xm = x0 - hx;
varargin{K} = xp;
fp = feval(Func,varargin{:});
varargin{K} = xm;
fm = feval(Func,varargin{:});
DF = (fp - fm) ./ (xp - xm);

end % xxDiffNum()