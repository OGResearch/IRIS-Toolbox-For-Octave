function [C,This] = protectquotes(C,This)
% protectquotes  [Not a public function] Replace quoted strings with
% replacement codes, and store the original content.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

pattern = '([''"])([^\n]*?)\1';
if ismatlab
    replaceFunc = @doReplace; %#ok<NASGU>
    C = regexprep(C,pattern,'${replaceFunc($1,$2)}');
else
    [ix1,ix2,tok] = regexp(C,pattern,'start','end','tokens');
    Ctmp = C(1:(ix1(1)-1));
    for tix = 1:length(ix1)-1
        Ctmp= [Ctmp doReplace(tok{tix}{1},tok{tix}{2}) C((ix2(tix)+1):(ix1(tix+1)-1))];
    end
    C = [Ctmp doReplace(tok{end}{1},tok{end}{2}) C(ix1(end):end)];
end

% Nested functions.

%**************************************************************************
    function K = doReplace(Quote,String)
        This.storage{end+1} = String;
        This.open{end+1} = Quote;
        This.close{end+1} = Quote;
        K = charcode(This);
    end % doReplace().
    
end
