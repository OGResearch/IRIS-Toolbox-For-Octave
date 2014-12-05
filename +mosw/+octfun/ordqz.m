function varargout = ordqz(varargin)
% ordqz  [Not a public function] Wrapper for Lapack's DGGES function. IRIS
% specific implementation of ordqz() for Octave.
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
    varargout = cell(1,nargout);
    if ispc
        [varargout{:}] = mosw.octfun.myordqz_win32(varargin{:});
    elseif isunix
        [varargout{:}] = mosw.octfun.myordqz_unix(varargin{:});
    else
        try
            [varargout{:}] = mosw.octfun.myordqz_unix(varargin{:});
        catch
            error('iris4octave:myordqz.mex','Are you on MAC? We need to recompile this mex-file for you.');
        end
    end
end

end