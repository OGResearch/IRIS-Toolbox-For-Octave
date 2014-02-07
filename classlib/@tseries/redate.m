function This = redate(This,OldDate,NewDate)
% redate  Change time dimension of a tseries object.
%
% Syntax
% =======
%
%     X = redate(X,oldDate,newDate)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object.
%
% * `OldDate` [ numeric ] - Base date that will be converted to a new date.
%
% * `NewDate` [ numeric ] - A new date to which the base date `oldDate`
% will be changed; `NewDate` need not be the same frequency as
% `OldDate`.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Output tseries object with identical data as the
% input tseries object, but with its time dimension changed.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

pp = inputParser();
if ismatlab
pp.addRequired('x',@(x) isa(x,'tseries'));
pp.addRequired('oldDate',@(isArg)is.numericscalar(isArg));
pp.addRequired('newDate',@(isArg)is.numericscalar(isArg));
pp.parse(This,OldDate,NewDate);
else
pp = pp.addRequired('x',@(x) isa(x,'tseries'));
pp = pp.addRequired('oldDate',@(isArg)is.numericscalar(isArg));
pp = pp.addRequired('newDate',@(isArg)is.numericscalar(isArg));
pp = pp.parse(This,OldDate,NewDate);
end

%--------------------------------------------------------------------------

xFreq = get(This,'freq');
oldFreq = datfreq(OldDate);

if oldFreq ~= xFreq
   utils.error('tseries', ...
      'Time series frequency and base date frequency must match.');
end

shift = round(This.start - OldDate);
This.start = NewDate + shift;

end