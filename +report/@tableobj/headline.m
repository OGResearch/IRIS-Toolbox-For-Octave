function C = headline(This)
% headline  [Not a public function] Latex code for table headline.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
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
    currentDates = dat2str(range,'dateFormat=',currentFmt);
    if ~isnan(yearFmt)
        yearDates = dat2str(range,'dateFormat=',yearFmt);
        yearDates = interpret(This,yearDates);
    end
    currentDates = interpret(This,currentDates);
    [year,per,freq] = dat2ypf(range); %#ok<ASGLU>
end

C = lead;
theFirstLine = lead;
hRule = lead;
yCount = 0;

colFootDate = [ This.options.colfootnote{1:2:end} ];
colFootText = This.options.colfootnote(2:2:end);

for i = 1 : nPer
    yCount = yCount + 1;
    colW = This.options.colwidth(min(i,end));
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
    firstLine = '';
    if isDates
        secondLine = currentDates{i};
        if isTwoLines
            firstLine = yearDates{i};
            isFirstLineChg = i == nPer ...
                || year(i) ~= year(i+1) ...
                || freq(i) ~= freq(i+1);
        end
    else
        secondLine = This.options.colstruct(i).name{2};
        if isTwoLines
            firstLine = This.options.colstruct(i).name{1};
            isFirstLineChg = i == nPer ...
                || ~isequalnFunc( ...
                This.options.colstruct(i).name{1}, ...
                This.options.colstruct(i+1).name{1});
            if isequalnFunc(firstLine,NaN)
                firstLine = '';
            end
        end
    end
    
    % Footnotes in the headings of individual columns.
    inx = datcmp(colFootDate,range(i));
    for j = find(inx)
        if ~isempty(colFootText{j})
            secondLine = [secondLine, ...
                footnotemark(This,colFootText{j})]; %#ok<AGROW>
        end
    end

    % Second (main) line.
    C = [C,'&\multicolumn{1}{',col,'}{', ...
        report.tableobj.makebox(secondLine, ...
        '',colW,This.options.headlinejust,''), ...
        '}']; %#ok<AGROW>
    % Print the first line text across this and all previous columns that have
    % the same date/text on the first line.
    if isTwoLines && isFirstLineChg
        command = [ ...
            '&\multicolumn{', ...
            sprintf('%g',yCount), ...
            '}{c}'];
        theFirstLine = [theFirstLine, ...
            command,'{', ...
            report.tableobj.makebox(firstLine, ...
            '',NaN,'',''), ...
            '}']; %#ok<AGROW>
        hRule = [hRule,command]; %#ok<AGROW>
        if ~isempty(firstLine)
            hRule = [hRule,'{\hrulefill}']; %#ok<AGROW>
        else
            hRule = [hRule,'{}']; %#ok<AGROW>
        end
        yCount = 0;
    end
end

if isTwoLines
    C = [theFirstLine,'\\[-8pt]',br,hRule,'\\',br,C];
end

if iscellstr(C)
    C = [C{:}];
end

end