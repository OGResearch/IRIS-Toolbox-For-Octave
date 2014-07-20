function This = altsyntax(This)
% altsyntax  [Not a public function] Replace alternative syntax with standard syntax.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Generic alternative syntax.

% Steady-state reference $ -> &.
This.Code = regexprep(This.Code,'\$\<([a-zA-Z]\w*)\>(?!\$)','&$1');

% Obsolete alternative syntax, throw a warning.
nBlkWarn = size(This.AltBlkNameWarn,1);
reportInx = false(nBlkWarn,1);

for iBlk = 1 : nBlkWarn
    ptn = ['\<',This.AltBlkNameWarn{iBlk,1},'\>'];
    if false % ##### MOSW
        replaceFunc = @doReplace; %#ok<NASGU>
        This.Code = regexprep(This.Code,ptn,'${replaceFunc()}');
    else
        This.Code = mosw.dregexprep(This.Code,ptn,'doReplace',[]); %#ok<UNRCH>
    end
end


    function C = doReplace()
        C = This.AltBlkNameWarn{iBlk,2};
        reportInx(iBlk) = true;
    end % doReplace()


% Create a cellstr {obsolete,new,obsolete,new,...}.
reportList = This.AltBlkNameWarn(reportInx,:).';
reportList = reportList(:).';

% Alternative or abbreviated syntax, do not report.
nAltBlk = size(This.AltBlkName,1);
for iBlk = 1 : nAltBlk
    This.Code = regexprep(This.Code, ...
        [This.AltBlkName{iBlk,1},'(?=\s)'], ...
        This.AltBlkName{iBlk,2});
end

if ~isempty(reportList)
    utils.warning('obsolete', [utils.errorparsing(This), ...
        'The model file keyword ''%s'' is obsolete, and will be removed ', ...
        'from IRIS in a future version. Use ''%s'' instead.'], ...
        reportList{:});
end

end