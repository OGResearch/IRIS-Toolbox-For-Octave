function [C,Temps] = speclatexcode(This)
% speclatexcode  [Not a public function] \LaTeX\ code for report object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

br = sprintf('\n');

C = '';

if This.options.centering
    C = [C,'\centering',br,br];
end

C = [C,begintypeface(This)];
Temps = {};
nChild = length(This.children);

for i = 1 : nChild
    ch = This.children{i};
    
    % Add a comment before each of the first-level objects.
    C = [C,br, ...
        '%--------------------------------------------------',br, ...
        '% Start of ',shortclass(ch),' ',ch.title,br]; %#ok<AGROW>
    
    C = [C,begintypeface(ch)]; %#ok<AGROW>
    
    % Generate command-specific latex code.
    [c,temps] = latexcode(ch);
    C = [C,c,'%',br]; %#ok<AGROW>
    Temps = [Temps,temps]; %#ok<AGROW>
    
    C = [C,endtypeface(ch)]; %#ok<AGROW>
    C = [C,br]; %#ok<AGROW>
    
    if i < nChild
        C = [C,ch.options.separator,br]; %#ok<AGROW>
    end
end

C = [C,endtypeface(This)];

end