function specdisp(This)
% specdisp  [Not a public function] Subclass specific disp line.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

fprintf('\tidentification: ');
if ~isempty(This.method)
    fprintf('''%s''\n',This.method);
else
    fprintf('''''\n');
end
    
end