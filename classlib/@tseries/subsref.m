function varargout = subsref(This,S,varargin)
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
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Handle a call from the Variable Editor.
d = dbstack();
isVE = length(d) > 1 && strcmp(d(2).file,'arrayviewfunc.m');
if isVE
    varargout{1} = subsref(This.data,S);
    return
end

if isnumeric(S)
    % Simplified syntax: subsref(X,Dates,Ref2,Ref3,...)
    dates = S;
    S = struct();
    S.type = '()';
    S.subs = [{dates},varargin];
end

% Time-recursive expressions.
if isanystr(S(1).type,{'{}','()'}) && isa(S(1).subs{1},'trec')
    varargout{1} = xxTRecExp(This,S,inputname(1));
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
        if strcmp(S(1).type,'.') && strcmp(S(1).subs,'args')
            utils.error('tseries:subsref', ...
                ['In time-recursive expressions, tseries objects must ', ...
                'be always indexed by trec objects.']);
        end
        % Give standard access to public properties.
        varargout{1} = builtin('subsref',This,S);
end

end


% Subfunctions...


%**************************************************************************


function X = xxTRecExp(This,S,InpName)
nSubs = length(S(1).subs);
% All references in 2nd and higher dimensions must be integer scalars or
% vectors.
valid = true(1,nSubs);
for i = 2 : nSubs
    valid(i) = isnumeric(S(1).subs{i}) ...
        && ~isempty(S(1).subs{i}) && all(isround(S(1).subs{i}));
end
if any(~valid)
    utils.error('tseries:subsref', ...
        'Invalid reference to tseries object in recursive expression.');
end
% Date vector in trec object must have the same date frequency as the
% referenced tseries object.
tr = S(1).subs{1};
if ~isempty(tr.Dates) && ~isnan(This.start) ...
        && ~freqcmp(tr.Dates(1),This.start)
    utils.error('tseries:subsref', ...
        'Frequency mismatch in recursive expression.');
end
% Create tsydney object.
X = tsydney(This,InpName,S(1).subs{:});
end % xxTRecExp()
