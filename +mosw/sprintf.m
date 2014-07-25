function Msg = sprintf(Msg,varargin)
% sprintf  [Not a public function] Workaround for Octave's sprintf.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if true % ##### MOSW
    % Do noting.
else
    % Remove HTML tags from `Message`.
    [Msg,varargin] = mosw.removehtml(Msg,varargin); %#ok<UNRCH>
end

Msg = sprintf(Msg,varargin{:});

end
