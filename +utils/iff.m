function X = iff(Cond,IfTrue,IfFalse)
% iff  [Not a public function] Functional form of the IF statement.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if length(Cond) ~= 1
   error('Condition must be a scalar.');
end

if Cond
   X = IfTrue;
else
   X = IfFalse;
end

end