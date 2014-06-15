function C = myclone(C,Clone)
% myclone  [Not a public function] Clone a preparsed code by appending a
% given prefix to all words except keywords.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ~preparser.mychkclonestring(Clone)
    utils.error('preparser', ...
        'Invalid clone string: ''%s''.', ...
        Clone);
end

ptn = '(?<!!)\<([A-Za-z]\w*)\>(?!\()';
if false % ##### MOSW
    rpl = '${strrep(Clone,''?'',$0)}';
    C = regexprep(C,ptn,rpl);
else
    C = mosw.dregexprep(C,ptn,@(C0) strrep(Clone,'?',C0),0); %#ok<UNRCH>
end

end