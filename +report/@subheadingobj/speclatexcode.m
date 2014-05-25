function C = speclatexcode(This,IChild,NChild)
% speclatexcode  [Not a public function] Produce LaTeX code for subheading objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% TODO: Check if `'justify='` `'centre'` works.

par = This.parent;
totalNCol = par.nlead + length(par.options.range);

if This.options.stretch
    if strncmpi(This.options.justify,'l',1) && ~isempty(par.vline)
        nCol = par.nlead + min(par.vline);
    else
        nCol = totalNCol;
    end
else
    nCol = par.nlead;
end

C = ['\multicolumn{$ncol$}', ...
    '{$just$}{$typeface$ $title$$footnotemark$}', ...
    ' $empty$ \\'];

if This.options.rowhighlight
      C = ['\rowcolor{highlightcolor}',C];
      This.options.justify = ['>{\columncolor{highlightcolor}}', ...
        This.options.justify];
      This.hInfo.package.colortbl = true;
      if IChild < NChild
          C = [C,'\rowcolor{white}'];
      end
end

C = strrep(C,'$just$',This.options.justify);
C = strrep(C,'$ncol$',sprintf('%g',nCol));
C = strrep(C,'$empty$',repmat('& ',1,totalNCol-nCol));
C = strrep(C,'$typeface$',This.options.typeface);
C = strrep(C,'$title$',interpret(This,This.title));
C = strrep(C,'$footnotemark$',footnotemark(This));

end
