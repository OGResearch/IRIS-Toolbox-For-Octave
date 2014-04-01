function [Flag,List] = isnan(This,varargin)
% isnan  Check for NaNs in model object.
%
% Syntax
% =======
%
%     [Flag,List] = isnan(M,'parameters')
%     [Flag,List] = isnan(M,'sstate')
%     [Flag,List] = isnan(M,'derivatives')
%     [Flag,List] = isnan(M,'solution')
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if at least one `NaN` value exists
% in the queried category.
%
% * `List` [ cellstr ] - List of parameters (if called with `'parameters'`)
% or variables (if called with `'sstate'`) that are assigned NaN in at
% least one parameterisation, or equations (if called with `'derivatives'`)
% that produce an NaN derivative in at least one parameterisation.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if ~isempty(varargin) && (ischar(varargin{1}) &&  ~strcmp(varargin{1},':'))
    request = lower(strtrim(varargin{1}));
    varargin(1) = [];
else
    request = 'all';
end

if ~isempty(varargin) && (isnumeric(varargin{1}) || islogical(varargin{1}))
    alt = varargin{1};
    if isinf(alt)
        alt = ':';
    end
else
    alt = ':';
end

%--------------------------------------------------------------------------

switch request
    case 'all'
        asgn = This.Assign(1,:,alt);
        inx = any(isnan(asgn),3);
        if nargout > 1
            List = This.name(inx);
        end
        Flag = any(inx);
    case {'p','parameter','parameters'}
        asgn = This.Assign(1,:,alt);
        inx = any(isnan(asgn),3);
        inx = inx & This.nametype == 4;
        if nargout > 1
            List = This.name(inx);
        end
        Flag = any(inx);
    case {'sstate'}
        % Check for NaNs in transition and measurement variables.
        asgn = This.Assign(1,:,alt);
        inx = any(isnan(asgn),3);
        inx = inx & (This.nametype == 1 | This.nametype == 2);
        if nargout > 1
            List = This.name(inx);
        end
        Flag = any(inx);
    case {'solution'}
        T = This.solution{1}(:,:,alt);
        R = This.solution{2}(:,:,alt);
        % Transition matrix can be empty in 2nd dimension (no lagged
        % variables).
        if size(T,1) > 0 && size(T,2) == 0
            inx = false(1,size(T,3));
        else
            inx = any(any(isnan(T),1),2) | any(any(isnan(R),1),2);
            inx = inx(:).';
        end
        Flag = any(inx);
        if nargout > 1
            List = inx;
        end
    case {'expansion'}
        expand = This.Expand{1}(:,:,alt);
        inx = isempty(expand) | any(any(isnan(expand),1),2);
        inx = inx(:)';
        if nargout > 1
            List = inx;
        end
        Flag = any(inx);
    case {'derivative','derivatives'}
        nalt = size(This.Assign,3);
        neqtn = length(This.eqtn);
        eqselect = true(1,neqtn);
        List = false(1,neqtn);
        Flag = false;
        for iAlt = 1 : nalt
            [~,~,nanDeriv] = myderiv(This,eqselect,iAlt,true,This.linear);
            Flag = Flag || any(nanDeriv);
            List(nanDeriv) = true;
        end
        List = This.eqtn(List);
    otherwise
        utils.error('Invalid request: ''%s''.',varargin{1});
end

end