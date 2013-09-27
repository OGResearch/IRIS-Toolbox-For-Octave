function [H] = legend(varargin)
% legend  Overloaded legend plot function for group objects. 
%
% Syntax
% =======
%
%     H = legend(G)
%     H = legend(AX,G)
%
% Input arguments
% ================
%
% * `G` [ group ] - Group object.
% * `AX` [ handle ] - Axes handle.
%
% Output arguments
% =================
%
% * `H` [ group ] - Legend handle.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if ishandle(varargin{1})
    H = legend(varargin{1},[varargin{2}.groupNames,'Other'],varargin{3:end}) ;
elseif isa(varargin{1},'group')
    H = legend([varargin{1}.groupNames,'Other'],varargin{2:end}) ;
else
    utils.error('group:legend','Error plotting legend.') ;
end

end


