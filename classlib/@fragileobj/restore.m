function C = restore(C,This,varargin)
% restore  [Not a public function] Replace protected charcodes with
% original strings.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

opt = passvalopt('fragileobj.restore',varargin{:});

%--------------------------------------------------------------------------

% Return immediately.
if isempty(C) || isempty(This)
    return
end

ptn = ['[',regexppattern(This),']'];
if ismatlab
    rplFunc = @doReplace; %#ok<NASGU>
    C = regexprep(C,ptn,'${rplFunc($0)}');
else
    cCodes = regexprep(ptn,'[\[\]\-]','');
    cCodes = back2highCharCode(cCodes(1:(length(cCodes/2)-1))):back2highCharCode(cCodes(length(cCodes/2):end));
    for ix = cCodes
        C = strrep(C,highCharCode2utf8(ix),doReplace(char(ix)));
    end
end

    function C = doReplace(K)
        if ismatlab
            dblK = double(K);
        else
            dblK = char2double(K);
        end
        K = dblK - This.offset;
        C = This.storage{K};
        if opt.delimiter
            C = [This.open{K}(1),C,This.close{K}(end)];
        end
    end

end
