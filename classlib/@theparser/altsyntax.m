function This = altsyntax(This)
% altsyntax  [Not a public function] Replace alternative syntax with standard syntax.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Generic alt syntax.

% Steady-state reference $ -> &.
This.code = regexprep(This.code,'\$\<([a-zA-Z]\w*)\>(?!\$)','&$1');

% Obsolete alternative syntax, throw a warning.
nBlkWarn = size(This.altBlkNameWarn,1);
reportInx = false(nBlkWarn,1);

% Nested functions are not visible from within `regexprep`, use a handle.
replaceFunc = @doReplace; %#ok<NASGU>
for iBlk = 1 : nBlkWarn
    This.code = regexprep(This.code, ...
        ['\<',This.altBlkNameWarn{iBlk,1},'\>'], ...
        '${replaceFunc()}');
end

    function C = doReplace()
        C = This.altBlkNameWarn{iBlk,2};
        reportInx(iBlk) = true;
    end

% Create a cellstr {obsolete,new,obsolete,new,...}.
reportList = This.altBlkNameWarn(reportInx,:).';
reportList = reportList(:).';

% Alternative or short-cut syntax, do not report.
nAltBlk = size(This.altBlkName,1);
for iBlk = 1 : nAltBlk
    This.code = regexprep(This.code, ...
        [This.altBlkName{iBlk,1},'(?=\s)'], ...
        This.altBlkName{iBlk,2});
end

if ~isempty(reportList)
    utils.warning('obsolete', [utils.errorparsing(This), ...
        'The model file keyword ''%s'' is obsolete, and will be removed ', ...
        'from IRIS in a future version. Use ''%s'' instead.'], ...
        reportList{:});
end

end