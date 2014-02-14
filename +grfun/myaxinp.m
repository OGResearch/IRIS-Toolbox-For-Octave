function [Ax,X,varargin] = myaxinp(varargin)
% myaxinp  [Not a public function] Handle input arguments to grfun
% functions that may or may not include handles to axes objects as the
% first input argument.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if length(varargin) > 1 && ~ischar(varargin{2})
    Ax = varargin{1}(:).';
    varargin(1) = [];
    if ~all(ishghandle(Ax))
        utils.error('grfun', ...
            'Invalid input handle to a graphics object.');
    end
    % Find axes objects (but not legends) amongst `Ax` and their immediate
    % children; this allows for figure handles.
    Ax = findobj(Ax,'type','axes','-depth',1,'-not','tag','legend');
else
    Ax = gca();
end

if ~isempty(varargin)
    X = varargin{1}(:).';
    varargin(1) = [];
else
    X = zeros(1,0);
end

end