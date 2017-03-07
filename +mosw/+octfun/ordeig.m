function EigVal = ordeig(T)
% ordeig  [Not a public function] Implementation of ordeig() function, missing
% in Octave.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if false % ##### MOSW
    
    % Matlab
    %--------
    error('iris:octfun', 'This function must not be used in Matlab!');
else
    
    % Octave
    %--------
    ndim = size(T,1);
    if (isreal(T) && ~isbanded(T,1,ndim-1)) || (iscomplex(T) && ~istriu(T))
      error('iris4octave:ordeig',['For ORDEIG(A), A must be block upper ',...
        'triangular with 1-by-1 and 2-by-2 blocks on its diagonal when A is real.']);
    end
    EigVal = zeros(ndim,1);
    ix = 1;
    while ix <= ndim
      if (ix == ndim) || (T(ix+1,ix) == 0)
        EigVal(ix) = T(ix,ix);
        ix = ix + 1;
      else
        kx = ix:ix+1;
        EigVal(kx) = eig(T(kx,kx));
        ix = ix + 2;
      end
    end
end

end