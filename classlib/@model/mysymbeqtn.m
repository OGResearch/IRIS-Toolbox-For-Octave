function eqtn = mysymbeqtn(eqtn)

eqtn = regexprep(eqtn,'x\(:,(\d+),t\)','x$1');
eqtn = regexprep(eqtn,'x\(:,(\d+),t\+0\)','x$1');
eqtn = regexprep(eqtn,'x\(:,(\d+),t\+(\d+)\)','x$1p$2');
eqtn = regexprep(eqtn,'x\(:,(\d+),t-(\d+)\)','x$1m$2');
eqtn = regexprep(eqtn,'L\((\d+)\)','L$1');

end