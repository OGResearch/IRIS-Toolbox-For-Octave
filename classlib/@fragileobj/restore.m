function C = restore(C,This,varargin)
% restore  [Not a public function] Replace protected charcodes with
% original strings.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

opt = passvalopt('fragileobj.restore',varargin{:});

%--------------------------------------------------------------------------

% Return immediately.
if isempty(C) || isempty(This)
    return
end
keyboard
ptn = ['[',regexppattern(This),']'];
if ismatlab
  rplFunc = @doReplace; %#ok<NASGU>
  C = regexprep(C,ptn,'${rplFunc($0)}');
else
  C = myregexprep(C,ptn,'${doReplace($0)}');
end

    function C = doReplace(K)
        K = double(K) - This.offset;
        C = This.storage{K};
        if opt.delimiter
            C = [This.open{K}(1),C,This.close{K}(end)];
        end
    end

end