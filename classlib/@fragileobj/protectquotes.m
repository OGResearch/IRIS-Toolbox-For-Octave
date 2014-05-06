function [C,This] = protectquotes(C,This)
% protectquotes  [Not a public function] Replace quoted strings with
% replacement codes, and store the original content.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

ptn = '([''"])([^\n]*?)\1';
% ##### MOSW:
% replaceFunc = @doReplace; %#ok<NASGU>
% C = regexprep(C,pattern,'${replaceFunc($1,$2)}');
C = mosw.dregexprep(C,ptn,@doReplace,[1,2]);


% Nested functions...


%**************************************************************************

    
    function K = doReplace(Quote,String)
        This.Storage{end+1} = String;
        This.Open{end+1} = Quote;
        This.Close{end+1} = Quote;
        K = charcode(This);
    end % doReplace()
    

end