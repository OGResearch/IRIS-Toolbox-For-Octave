function Msg = sprintf(Msg,varargin)
% sprintf  [Not a public function] Workaround for Octave's sprintf.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if false % ##### MOSW
    % Do noting.
else
    % Remove HTML tags from `Message`.
    Msg = mosw.removehtml(Msg); %#ok<UNRCH>
end

Msg = sprintf(Msg,varargin{:});

end
