function C = headline(This)
% headline  [Not a public function] Latex code for table headline.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

isDates = isempty(This.options.colstruct);
if isDates
    range = This.options.range;
else
    nCol = length(This.options.colstruct);
    range = 1 : nCol;
end

dateFormat = This.options.dateformat;
nLead = This.nlead;
vLine = This.vline;

br = sprintf('\n');

if isDates
    yearFmt = dateFormat{1};
    currentFmt = dateFormat{2};
    twoLines = isDates && ~isequaln(yearFmt,NaN);
else
    twoLines = false;
    for i = 1 : nCol
        twoLines = ...
            ~isequaln(This.options.colstruct(i).name{1},NaN);
        if twoLines
            break
        end
    end
end

leading = '&';
leading = leading(ones(1,nLead-1));
if isempty(range)
    if isnan(yearFmt)
        C = leading;
    else
        C = [leading,br,'\\',leading];
    end
    return
end
range = range(:).';
nPer = length(range);
if isDates
    currentDates = dat2str(range,'dateformat',currentFmt);
    if ~isnan(yearFmt)
        yearDates = dat2str(range,'dateformat',yearFmt);
        yearDates = interpret(This,yearDates);
    end
    currentDates = interpret(This,currentDates);
    [year,per,freq] = dat2ypf(range); %#ok<ASGLU>
end

C = leading;
firstLine = leading;
hRule = leading;
yCount = 0;

for i = 1 : nPer
    yCount = yCount + 1;
    colW = This.options.colwidth(min(i,end));
    col = This.options.headlinejust;
    if i == 1 && any(vLine == 0)
        col = ['|',col]; %#ok<AGROW>
    end
    if any(vLine == i)
        col = [col,'|']; %#ok<AGROW>
    end
    if isDates
        secondLineText = currentDates{i};
        if twoLines
            firstLineText = yearDates{i};
            firstLineChg = i == nPer ...
                || year(i) ~= year(i+1) ...
                || freq(i) ~= freq(i+1);
        end
    else
        secondLineText = This.options.colstruct(i).name{2};
        if twoLines
            firstLineText = This.options.colstruct(i).name{1};
            firstLineChg = i == nPer ...
                || ~isequaln( ...
                This.options.colstruct(i).name{1}, ...
                This.options.colstruct(i+1).name{1});
            if isequaln(firstLineText,NaN)
                firstLineText = '';
            end
        end
    end
    % Second line.
    C = [C,'&\multicolumn{1}{',col,'}{', ...
        report.tableobj.makebox(secondLineText, ...
        '',colW,This.options.headlinejust,''), ...
        '}']; %#ok<AGROW>
    % Print the first line text across this and all previous columns that have
    % the same date/text on the first line.
    if twoLines && firstLineChg
        command = [ ...
            '&\multicolumn{', ...
            sprintf('%g',yCount), ...
            '}{c}'];
        firstLine = [firstLine,command,'{', ...
            report.tableobj.makebox(firstLineText, ...
            '',NaN,'',''), ...
            '}']; %#ok<AGROW>
        hRule = [hRule,command]; %#ok<AGROW>
        if ~isempty(firstLineText)
            hRule = [hRule,'{\hrulefill}']; %#ok<AGROW>
        else
            hRule = [hRule,'{}']; %#ok<AGROW>
        end
        yCount = 0;
    end
end
if twoLines
    C = [firstLine,'\\[-8pt]',br,hRule,'\\',br,C];
end

if iscellstr(C)
    C = [C{:}];
end

end