function This = refresh(This,IAlt)
% refresh  Refresh dynamic links.
%
% Syntax
% =======
%
%     M = refresh(M)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object whose dynamic links will be refreshed.
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with dynamic links refreshed.
%
% Description
% ============
%
% Example
% ========
%
%     m = refresh(m);
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if isempty(This.Refresh)
   return
end

nalt = size(This.Assign,3);
try
    IAlt; %#ok<VUNUS>
catch %#ok<CTCH>
    IAlt = 1 : nalt;
end

%--------------------------------------------------------------------------

% We cannot use cellfun to evaluate the equations because dynamic links can
% be recursive.

eqtn = This.eqtnF(This.eqtntype == 4);
n = size(This.Assign,2);
x = [This.Assign(1,:,IAlt),This.stdcorr(1,:,IAlt)];
x = permute(x,[3,2,1]);
for j = 1 : length(This.Refresh)
   namepos = This.Refresh(j);
   x(:,namepos) = feval(eqtn{j},x,1);
end
x = ipermute(x,[3,2,1]);
This.Assign(1,:,IAlt) = x(1,1:n,:);
This.stdcorr(1,:,IAlt) = x(1,n+1:end,:);

end