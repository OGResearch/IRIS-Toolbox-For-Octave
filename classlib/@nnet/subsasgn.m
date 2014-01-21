function This = subsasgn(This,S,B)
% subsasgn  Subscripted assignment for nnet objects.
%
% Syntax for assigning parameterisations from other object
% =========================================================
%
%     M(Inx) = N
%
% Syntax for deleting specified parameterisations
% ================================================
%
%     M(Inx) = []
%
% Input arguments
% ================
%
% Output arguments
% =================
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

switch S(1).type
    case {'()','{}'}
        if ~isempty(B)
            % Check dimensions
            if numel(S.subs) ~= B.nAlt
                utils.error('nnet:subsasgn',...
                    'Subscripted dimension mismatch.') ;
            end
            
            if ~aeq(This,B)
                utils.error('nnet:subsasgn',...
                    'Network structures must be the same.') ;
            end
        
            % Work
            This.Params(:,S.subs{1}) = B.Params ;
        else
            % Delete this parameterization
            This.Params(:,S.subs{1}) = [] ;
        end
        
    otherwise
        % Give standard access to public properties
        This = builtin('subsasgn',This,S,B);
        
end

end

