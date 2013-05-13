function C = latexonerow(This,IRow,Time,Data,Mark,Text)
% latexonerow  [Not a public function] LaTeX code for one table band row.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

br = sprintf('\n');

C = latexonerow@report.seriesobj(This, ...
    IRow,Time,Data(:,1),Mark,Text);

lowM = This.options.low;
highM = This.options.high;
if ~isempty(Mark)
    lowM = [Mark,'--',lowM];
    highM = [Mark,'--',highM];
end
lowSt = latex.stringsubs(lowM);
highSt = latex.stringsubs(highM);
C = [C,br,...
    '& & {',This.options.bandtypeface,'{',lowSt,'}}', ...
    latexdata(This,IRow,Time,Data(:,2), ...
    This.options.bandtypeface,lowM,Text), ...
    '\\',br,...
    '& & {',This.options.bandtypeface,'{',highSt,'}}', ...
    latexdata(This,IRow,Time,Data(:,3), ...
    This.options.bandtypeface,highM,Text), ...
    '\\'];

end