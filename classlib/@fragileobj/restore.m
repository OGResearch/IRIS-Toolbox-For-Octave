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
rplFunc = @doReplace; %#ok<NASGU>
C = regexprep(C,ptn,'${rplFunc($0)}');

    function C = doReplace(K)
        K = double(K) - This.offset;
        C = This.storage{K};
        if opt.delimiter
            C = [This.open{K}(1),C,This.close{K}(end)];
        end
    end

end