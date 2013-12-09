function C = latexonerow(This,Row,Time,Data,Mark,Text)
% latexonerow  [Not a public function] LaTeX code for one table series row.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

br = sprintf('\n');
nPer = length(Data);
markString = latex.stringsubs(Mark);
C = [ ...
    doLatexCaption(), ...
    footnotemark(This), ...
    ' & ',doLatexUnits(), ...
    ' & ',markString, ...
    latexdata(This,Row,Time,Data,'',Mark,Text), ...
    ' \\', ...
    ];

% Nested functions.

%**************************************************************************
    function C = doLatexCaption()
        if Row == 1
            tit = latex.stringsubs(This.title);
            subtit = latex.stringsubs(This.subtitle);
            if isempty(subtit)
                C = tit;
                return
            end
            C = ['\multicolumn{3}{l}{',tit,'}', ...
                repmat(' &',1,nPer),' \\',br];
            C = [C,subtit];
        else
            C = '';
        end
    end % doLatexCaption().

%**************************************************************************
    function C = doLatexUnits()
        if Row == 1
            C = latex.stringsubs(This.options.units);
            C = ['~',C];
        else
            C = '';
        end
    end % doLatexUnits().

end
