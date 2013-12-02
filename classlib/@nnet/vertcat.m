function This = vertcat(This,varargin)
% vertcat  Combine two compatible nnet objects in one object with multiple parameterisations.
%
% Syntax
% =======
%
%     M = [M1,M2,...]
%
% Input arguments
% ================
%
% * `M1`, `M2` [ nnet ] - Compatible nnet objects that will be combined;
% the input models must have the same layout.
%
% Output arguments
% =================
%
% * `M` [ nnet ] - Output nnet object that combines the input nnet
% objects as multiple parameterisations.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin == 1
    return
end

ind = This.nAlt ;
for ii = 1 : numel(varargin)
    if ~aeq(This,varargin{ii})
        utils.error('nnet:horzcat',...
            'Network structures must be the same.') ;
    end
    
    This.Params(:,ind+1:ind+varargin{ii}.nAlt) ...
        = varargin{ii}.Params ;
    ind = ind + varargin{ii}.nAlt ;
end

end



