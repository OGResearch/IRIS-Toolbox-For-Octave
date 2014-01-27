function savecsvdata(O,FName)
% savecsvdata  [Not a public function] Print data to CSV text file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

nameRow = O.namerow;
dates = O.dates;
data = O.data;

if isfield(O,'delimiter')
    delimiter = O.delimiter;
else
    delimiter = ',';
end
fstr = [delimiter,'"%s"'];

if isfield(O,'commentrow')
    commentRow = O.commentrow;
else
    commentRow = {};
end
isCommentRow = ~isempty(commentRow);

if isfield(O,'classrow')
    classRow = O.classrow;
else
    classRow = {};
end
isClassRow = ~isempty(classRow);

if isfield(O,'unitrow')
    unitRow = O.unitrow;
else
    unitRow = {};
end
isUnitRow = ~isempty(unitRow);

if isfield(O,'nanstring')
    nanString = O.nanstring;
else
    nanString = 'NaN';
end
isNanString = ~strcmpi(nanString,'NaN');

if isfield(O,'format')
    format = O.format;
else
    format = '%.8e';
end

if isfield(O,'highlight')
    highlight = O.highlight;
else
    highlight = [];
end
isHighlight = ~isempty(highlight);

isUserData = isfield(O,'userdata');

%--------------------------------------------------------------------------

% Create an empty buffer.
c = '';
br = sprintf('\n');

% Write database user data.
if isUserData
    userData = utils.any2str(O.userdata);
    userData = strrep(userData,'"','''');
    c = [c,'"Userdata[',O.userdatafieldname,'] ->"',delimiter,'"',userData,'"',br];
end

% Write name row.
if isHighlight
    nameRow = [{''},nameRow];
end
c = [c,'"Variables ->"',xxPrintCharCells(nameRow)];

% Write comments.
if isCommentRow
    if isHighlight
        commentRow = [{''},commentRow];
    end
    c = [c,br,'"Comments ->"',xxPrintCharCells(commentRow)];
end

% Write units.
if isUnitRow
    if isHighlight
        unitRow = [{''},unitRow];
    end
    c = [c,br,'"Units ->"',xxPrintCharCells(unitRow)];
end

% Write classes.
if isClassRow
    if isHighlight
        classRow = [{''},classRow];
    end
    c = [c,br,'"Class[Size] ->"',xxPrintCharCells(classRow)];
end

% Create cellstr with date strings.
nDates = length(dates);

% Handle escape characters.
dates = strrep(dates,'\','\\');
dates = strrep(dates,'%','%%');

% Create format string fot the imaginary parts of data; they need to be
% always printed with a plus or minus sign.
iFormat = [format,'i'];
if isempty(strfind(iFormat,'%+')) && isempty(strfind(iFormat,'%0+'))
    iFormat = strrep(iFormat,'%','%+');
end

% Find columns that have at least one non-zero imag. These column will
% be printed as complex numbers.
nRow = size(data,1);
nCol = size(data,2);

% Combine real and imag columns in an extended data matrix.
xData = zeros(nRow,2*nCol);
xData(:,1:2:end) = real(data);
iData = imag(data);
xData(:,2:2:end) = iData;

% Find imag columns and create positions of zero-only imag columns that
% will be removed.
iCol = any(iData ~= 0,1);
removeCol = 2*(1 : nCol);
removeCol(iCol) = [];
% Check for the occurence of imaginary NaNs.
isImagNan = any(isnan(iData(:)));
% Remove zero-only imag columns from the extended data matrix.
xData(:,removeCol) = [];
% Create a sequence of formats for one line.
formatLine = cell(1,nCol);
% Format string for columns that have imaginary numbers.
formatLine(iCol) = {[delimiter,format,iFormat]};
% Format string for columns that only have real numbers.
formatLine(~iCol) = {[delimiter,format]};
formatLine = [formatLine{:}];

% We must create a format line for each date because the date strings
% vary.
br = sprintf('\n');
formatData = '';
for i = 1 : size(data,1)
    if i <= nDates
        thisDate = ['"',dates{i},'"'];
    else
        thisDate = '"NaN"';
    end
    if isHighlight
        if i <= nDates && highlight(i)
            thisDate = [thisDate,delimiter,'"***"']; %#ok<AGROW>
        else
            thisDate = [thisDate,delimiter,'""']; %#ok<AGROW>
        end
    end
    formatData = [formatData,br,thisDate,formatLine]; %#ok<AGROW>
end
cc = sprintf(formatData,xData.');

% NaNi is never printed with the leading sign. Replace NaNi with +NaNi. We
% should also control for the occurence of NaNi in date strings but we
% don't as this is quite unlikely (and would not be easy).
if isImagNan
    cc = strrep(cc,'NaNi','+NaNi');
end

% Replace NaNs in the date/data matrix with a user-supplied string. We
% don't protect NaNs in date strings; these too will be replaced.
if isNanString
    cc = strrep(cc,'NaN',nanString);
end

% Splice the headings and the data, and save the buffer. No need to put
% a line break between `c` and `cc` because that the `cc` does start
% with a line break.
char2file([c,cc],FName);

    function s = xxPrintCharCells(c)
        s = '';
        if isempty(c) || ~iscellstr(c)
            return
        end
        s = sprintf(fstr,c{:});
    end% xxPrintCharCells()

end