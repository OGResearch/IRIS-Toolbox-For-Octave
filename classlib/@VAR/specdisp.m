function specdisp(This)
% specdisp  [Not a public function] Subclass specific disp line.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

fprintf('\tinstruments: ');
if isempty(This.INames)
    fprintf('empty');
else
    fprintf('%s',strfun.displist(This.INames));
end
fprintf('\n');

end