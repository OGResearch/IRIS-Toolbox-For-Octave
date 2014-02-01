function C = grabcommentblk(Trace)
% grabcommentblk  [Not a public function] Grab curly comment block placed after the calling function.
%
% Backend IRIS function.
% No help provided.


% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

C = file2char(Trace.file,'cellstrs');
C = [C{Trace.line+1:end}];
C = strfun.converteols(C);
tok = regexp(C,'^[ \t]*%\{[ \t]*$(.*?)^[ \t]*%\}[ \t]*$', ...
    'tokens','once','lineanchors');
if ~isempty(tok)
    C = tok{1};
else
    C = '';
end

end