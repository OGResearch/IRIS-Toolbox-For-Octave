function specdisp(This)
% specdisp  [Not a public function] Subclass specific disp line.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

fprintf('\tidentification: ');
if ~isempty(This.method)
    u = unique(This.method);
    fprintf('%s',strfun.displist(u));
else
    fprintf('empty');
end
fprintf('\n');

end