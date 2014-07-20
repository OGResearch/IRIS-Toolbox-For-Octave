function C = headline(This)
% headline  [Not a public function] Latex code for table headline.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    isequaln(0,0);
    isequalnFunc = @isequaln;
catch
    isequalnFunc = @isequalwithequalnans;
end

isDates = isempty(This.options.colstruct);
if isDates
    range = This.options.range;
else
    nCol = length(This.options.colstruct);
    range = 1 : nCol;
end

dateFormat = This.options.dateformat;
nLead = This.nlead;

br = sprintf('\n');

if isDates
    yearFmt = dateFormat{1};
    currentFmt = dateFormat{2};
    isTwoLines = isDates && ~isequalnFunc(yearFmt,NaN);
else
    isTwoLines = false;
    for i = 1 : nCol
        isTwoLines = ~isequalnFunc(This.options.colstruct(i).name{1},NaN);
        if isTwoLines
            break
        end
    end
end

lead = '&';
lead = lead(ones(1,nLead-1));
if isempty(range)
    if isnan(yearFmt)
        C = lead;
    else
        C = [lead,br,'\\',lead];
    end
    return
end

range = range(:).';
nPer = length(range);
if isDates
    currentDates = dat2str(range, ...
        'dateFormat=',currentFmt, ...
        'freqLetters=',This.options.freqletters, ...
        'months=',This.options.months, ...
        'standinMonth=',This.options.standinmonth);
    if ~isnan(yearFmt)
        yearDates = dat2str(range, ...
            'dateFormat=',yearFmt, ...
            'freqLetters=',This.options.freqletters, ...
            'months=',This.options.months, ...
            'standinMonth=',This.options.standinmonth);
        yearDates = interpret(This,yearDates);
    end
    currentDates = interpret(This,currentDates);
    [year,per,freq] = dat2ypf(range); %#ok<ASGLU>
end

firstLine = lead; % First line.
secondLine = lead; % Main line.
divider = lead; % Dividers between first and second lines.
yCount = 0;

colFootDate = [ This.options.colfootnote{1:2:end} ];
colFootText = This.options.colfootnote(2:2:end);

for i = 1 : nPer
    isLastCol = i == nPer;
    yCount = yCount + 1;
    colW = This.options.colwidth(min(i,end));
    f = '';
    if isDates
        s = currentDates{i};
        if isTwoLines
            f = yearDates{i};
            isFirstLineChg = isLastCol ...
                || (year(i) ~= year(i+1) || freq(i) ~= freq(i+1));
        end
    else
        s = This.options.colstruct(i).name{2};
        if isTwoLines
            f = This.options.colstruct(i).name{1};
            isFirstLineChg = isLastCol ...
                || ~isequalnFunc(This.options.colstruct(i).name{1}, ...
                This.options.colstruct(i+1).name{1});
            if isequalnFunc(f,NaN)
                f = '';
            end
        end
    end
    
    % Footnotes in the headings of individual columns.
    inx = datcmp(colFootDate,range(i));
    for j = find(inx)
        if ~isempty(colFootText{j})
            s = [s, ...
                footnotemark(This,colFootText{j})]; %#ok<AGROW>
        end
    end

    col = This.options.headlinejust;
    if any(This.highlight == i)
        col = upper(col);
    end
    if i == 1 && any(This.vline == 0)
        col = ['|',col]; %#ok<AGROW>
    end
    if any(This.vline == i)
        col = [col,'|']; %#ok<AGROW>
    end    

    % Second=Main line.
    s = ['&\multicolumn{1}{',col,'}{', ...
        report.tableobj.makebox(s,'',colW,This.options.headlinejust,''), ...
        '}'];
    secondLine = [secondLine,s]; %#ok<AGROW>
    
    % Print the first line text across this and all previous columns that have
    % the same date/text on the first line.
    % hRule = [hRule,'&\multicolumn{1}{c|}{}'];
    if isTwoLines && isFirstLineChg
        command = [ ...
            '&\multicolumn{', ...
            sprintf('%g',yCount), ...
            '}{c}'];
        firstLine = [firstLine,command, ...
            '{',report.tableobj.makebox(f,'',NaN,'',''),'}']; %#ok<AGROW>
        divider = [divider,command]; %#ok<AGROW>
        if ~isempty(f)
            divider = [divider,'{\hrulefill}']; %#ok<AGROW>
        else
            divider = [divider,'{}']; %#ok<AGROW>
        end
        yCount = 0;
    end
end

if isTwoLines
    C = [firstLine,'\\[-8pt]',br,divider,'\\',br,secondLine];
else
    C = secondLine;
end

if iscellstr(C)
    C = [C{:}];
end

end