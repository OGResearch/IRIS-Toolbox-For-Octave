function [C,This] = protectquotes(C,This)
% protectquotes  [Not a public function] Replace quoted strings with
% replacement codes, and store the original content.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

pattern = '([''"])([^\n]*?)\1';
replaceFunc = @doReplace; %#ok<NASGU>
if ismatlab
    C = regexprep(C,pattern,'${replaceFunc($1,$2)}');
else
    C = myregexprep(C,pattern,'${doReplace($1,$2)}');
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