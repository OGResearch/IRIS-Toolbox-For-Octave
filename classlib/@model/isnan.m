function [Flag,List] = isnan(This,varargin)
% isnan  Check for NaNs in model object.
%
% Syntax
% =======
%
%     [Flag,List] = isnan(M,'parameters')
%     [Flag,List] = isnan(M,'sstate')
%     [Flag,List] = isnan(M,'derivatives')
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
% or variables (if called with `'variables'`) that are assigned NaN in at
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
% -Copyright (c) 2007-2013 IRIS Solutions Team.

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
        assign = This.Assign(1,:,alt);
        inx = any(isnan(assign),3);
        if nargout > 1
            List = This.name(inx);
        end
        Flag = any(inx);
    case {'p','parameter','parameters'}
        assign = This.Assign(1,:,alt);
        inx = any(isnan(assign),3) & This.nametype == 4;
        if nargout > 1
            List = This.name(inx);
        end
        Flag = any(inx);
    case {'sstate'}
        assign = This.Assign(1,:,alt);
        inx = any(isnan(assign),3) & This.nametype ~= 4;
        if nargout > 1
            List = This.name(inx);
        end
        Flag = any(inx);
    case {'solution'}
        sol = This.solution{1}(:,:,alt);
        inx = isempty(sol) | any(any(isnan(sol),1),2);
        inx = inx(:)';
        if nargout > 1
            List = inx;
        end
        Flag = any(inx);
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