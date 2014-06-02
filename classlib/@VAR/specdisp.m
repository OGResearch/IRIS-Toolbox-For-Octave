function specdisp(This)
% specdisp  [Not a public function] Subclass specific disp line.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Exogenous inputs.
fprintf('\texogenous: [%g] ',length(This.XNames));
if ~isempty(This.XNames)
    fprintf('%s',strfun.displist(This.XNames));
end
fprintf('\n');

% Conditioning instruments.
fprintf('\tinstruments: [%g] ',length(This.INames));
if ~isempty(This.INames)
    fprintf('%s',strfun.displist(This.INames));
end
fprintf('\n');

% Group names for panel objects.
fprintf('\tgroups: ');
if isempty(This.GroupNames)
    fprintf('implicit');
else
    fprintf('[%g] %s',length(This.GroupNames), ...
        strfun.displist(This.GroupNames));
end
fprintf('\n');

end