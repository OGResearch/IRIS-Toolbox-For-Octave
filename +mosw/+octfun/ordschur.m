function varargout = ordschur(varargin)
% ordschur  [Not a public function] Wrapper for Lapack's DGEES function. IRIS
% specific implementation of ordschur() for Octave.
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
    varargout = cell(1,max([1,nargout]));
    [varargout{:}] = mosw.octfun.myordschur(varargin{:});
end

end