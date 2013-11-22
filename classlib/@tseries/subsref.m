function varargout = subsref(This,S)
% subsref  Subscripted reference function for tseries objects.
%
% Syntax returning numeric array
% ===============================
%
%     ... = X(Dates)
%     ... = X(Dates,...)
%
% Syntax returning tseries object
% ================================
%
%     ... = X{Dates}
%     ... = X{Dates,...}
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object.
%
% * `Dates` [ numeric ] - Dates for which the time series observations will
% be returned, either as a numeric array or as another tseries object.
%
% Description
% ============
%
% Example
% ========

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Handle a call from the Variable Editor.
d = dbstack();
isVE = length(d) > 1 && strcmp(d(2).file,'arrayviewfunc.m');
if isVE
    varargout{1} = subsref(This.data,S);
    return
end

% Run `mylagorlead` to tell if the first reference is a lag/lead. If yes,
% the startdate of `x` will be adjusted withing `mylagorlead`.
[This,S] = mylagorlead(This,S);
if isempty(S)
    varargout{1} = This;
    return
end

switch S(1).type
    case '()'
        % Return a tseries object.
        [This,Range] = mygetdata(This,S(1).subs{:});
        varargout{1} = This;
        varargout{2} = Range;
    case '{}'
        % Return an array.
        [~,~,This] = mygetdata(This,S(1).subs{:});
        This = mytrim(This);
        S(1) = [];
        if isempty(S)
            varargout{1} = This;
        else
            varargout{1} = subsref(This,S);
        end
    otherwise
        % Give standard access to public properties.
        varargout{1} = builtin('subsref',This,S);
end

end