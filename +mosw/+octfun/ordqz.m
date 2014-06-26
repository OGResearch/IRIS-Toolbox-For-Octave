function varargout = ordqz(varargin)
% ordqz  [Not a public function] Wrapper for Lapack's DGGES function. IRIS
% specific implementation of ordqz() for Octave.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if is.matlab()
    
    % Matlab
    %--------
    error('iris:octfun', 'This function must not be used in Matlab!');
else
    
    % Octave
    %--------
    varargout = cell(1,nargout);
    [varargout{:}] = mosw.octfun.myordqz(varargin{:});
end

end