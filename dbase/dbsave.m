function Saved = dbsave(D,FName,Dates,varargin)
% dbsave  Save database as CSV file.
%
% Syntax
% =======
%
%     List = dbsave(D,FName)
%     List = dbsave(D,FName,Dates,...)
%
% Output arguments
% =================
%
% * `List` [ cellstr ] - - List of actually saved database entries.
%
% Input arguments
% ================
%
% * `D` [ struct ] - Database whose tseries and numeric entries will be
% saved.
%
% * `FName` [ char ] - Filename under which the CSV will be saved,
% including its extension.
%
% * `Dates` [ numeric | *`Inf`* ] Dates or date range on which the tseries
% objects will be saved.
%
% Options
% ========
%
% * `'class='` [ *`true`* | false ] - Include a row with class and size
% specifications.
%
% * `'comment='` [ *`true`* | `false` ] - Include a row with comments for tseries
% objects.
%
% * `'decimal='` [ numeric | *empty* ] - Number of decimals up to which the
% data will be saved; if empty the `'format'` option is used.
%
% * `'format='` [ char | *`'%.8e'`* ] Numeric format that will be used to
% represent the data, see `sprintf` for details on formatting, The format
% must start with a `'%'`, and must not include identifiers specifying
% order of processing, i.e. the `'$'` signs, or left-justify flags, the
% `'-'` signs.
%
% * `'freqLetters='` [ char | *`'YHQBM'`* ] - Five letters to represent the
% five possible date frequencies (annual, semi-annual, quarterly,
% bimonthly, monthly).
%
% * `'nan='` [ char | *`'NaN'`* ] - String that will be used to represent
% NaNs.
%
% * `'saveSubdb='` [ `true` | *`false`* ] - Save sub-databases (structs
% found within the struct `D`); the sub-databases will be saved to separate
% CSF files.
%
% * `'userData='` [ char | *'userdata'* ] - Field name from which
% any kind of userdata will be read and saved in the CSV file.
%
% Description
% ============
%
% The data saved include also imaginary parts of complex numbers.
%
% Saving user data with the database
% ------------------------------------
%
% If your database contains field named `'userdata='`, this will be saved
% in the CSV file on a separate row. The `'userdata='` field can be any
% combination of numeric, char, and cell arrays and 1-by-1 structs.
%
% You can use the `'userdata='` field to describe the database or preserve
% any sort of metadata. To change the name of the field that is treated as
% user data, use the `'userData='` option.
%
% Example 1
% ==========
%
% Create a simple database with two time series.
%
%     d = struct();
%     d.x = tseries(qq(2010,1):qq(2010,4),@rand);
%     d.y = tseries(qq(2010,1):qq(2010,4),@rand);
%
% Add your own description of the database, e.g.
%
%     d.userdata = {'My database',datestr(now())};
%
% Save the database as CSV using `dbsave`,
%
%     dbsave(d,'mydatabase.csv');
%
% When you later load the database,
%
%     d = dbload('mydatabase.csv')
%
%     d = 
%
%        userdata: {'My database'  '23-Sep-2011 14:10:17'}
%               x: [4x1 tseries]
%               y: [4x1 tseries]
%
% the database will preserve the `'userdata='` field.
%
% Example 2
% -----------
%
% To change the field name under which you store your own user data, use
% the `'userdata='` option when running `dbsave`,
%
%     d = struct();
%     d.x = tseries(qq(2010,1):qq(2010,4),@rand);
%     d.y = tseries(qq(2010,1):qq(2010,4),@rand);
%     d.MYUSERDATA = {'My database',datestr(now())};
%     dbsave(d,'mydatabase.csv',Inf,'userData=','MYUSERDATA');
%
% The name of the user data field is also kept in the CSV file so that
% `dbload` works fine in this case, too, and returns a database identical
% to the saved one,
%
%     d = dbload('mydatabase.csv')
%
%     d = 
%
%        MYUSERDATA: {'My database'  '23-Sep-2011 14:10:17'}
%                 x: [4x1 tseries]
%                 y: [4x1 tseries]

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    Dates;
catch %#ok<CTCH>
    Dates = Inf;
end

% Allow both dbsave(D,FName) and dbsave(FName,D).
if ischar(D) && isstruct(FName)
    [D,FName] = deal(FName,D);
end

% Parse input arguments.
pp = inputParser();
pp.addRequired('D',@isstruct);
pp.addRequired('FName',@ischar);
pp.addRequired('Dates',@isnumeric);
pp.parse(D,FName,Dates);

% Parse options.
opt = passvalopt('dbase.dbsave',varargin{:});

% Run Dates/datdefaults to substitute the default (irisget) date format
% options for 'config'.
opt = datdefaults(opt);

% Remove double quotes from the date format string. This is because the
% double quotes are used to delimit the CSV cells.
[flag,opt.dateformat] = strfun.findremove(opt.dateformat,'"');
if flag
    warning('iris:data', ...
        '\n*** Double quotes removed from date format string.');
end

% Set up the formatting string.
if isempty(opt.decimal)
    format = opt.format;
else
    format = ['%.',sprintf('%g',opt.decimal),'f'];
end

%--------------------------------------------------------------------------

if isequal(Dates,Inf)
    Dates = dbrange(D);
else
    Dates = Dates(:)';
end

% Create saving struct.
o = struct();

% Handle userdata first, and remove them from the database so that they are
% not processed as a regular field.
if ~isempty(opt.userdata) && isfield(D,opt.userdata)
    o.userdata = D.(opt.userdata);
    o.userdatafieldname = opt.userdata;
    D = rmfield(D,opt.userdata);
end

List = fieldnames(D).';

% Initialise the data matrix as a N-by-1 vector of NaNs to mimic the Dates.
% This first column will fill in all entries.
data = nan(length(Dates),1);

nameRow = {};
classRow = {};
commentRow = {};
savedInx = false(size(List));
isSubDb = false(size(List));

for i = 1 : numel(List)
    
    name = List{i};
    
    if istseries(D.(name))
        tmpData = D.(name)(Dates);
        tmpComment = comment(D.(name));
        savedInx(i) = true;
        tmpClass = 'tseries';
    elseif isnumeric(D.(name))
        tmpData = D.(name);
        tmpComment = {''};
        savedInx(i) = true;
        tmpClass = class(D.(name));
    elseif isstruct(D.(name))
        isSubDb(i) = true;
    else
        continue
    end
    
    tmpData = double(tmpData);
    tmpSize = size(tmpData);
    tmpData = tmpData(:,:);
    [tmpRows,tmpCols] = size(tmpData);
    if tmpCols == 0
        continue
    elseif tmpCols > 1
        tmpComment(end+1:tmpCols) = {''};
    end
    
    % Add data, expand first dimension if necessary.
    nRows = size(data,1);
    if nRows < tmpRows
        data(end+1:tmpRows,:) = NaN;
    elseif size(data,1) > tmpSize(1)
        tmpData(end+1:nRows,:) = NaN;
    end
    data = [data,tmpData]; %#ok<*AGROW>
    nameRow{end+1} = List{i};
    classRow{end+1} = [tmpClass,xxPrintSize(tmpSize)];
    commentRow(end+(1:tmpCols)) = tmpComment;
    if tmpCols > 1
        nameRow(end+(1:tmpCols-1)) = {''};
        classRow(end+(1:tmpCols-1)) = {''};
    end
    
end

% Remove the pretend date column.
data(:,1) = [];

Saved = List(savedInx);

o.dates = dat2str(Dates(:),opt);
o.data = data;
o.namerow = nameRow;
o.nanstring = opt.nan;
o.format = format;
if opt.comment
    o.commentrow = commentRow;
end
if opt.class
    o.classrow = classRow;
end

utils.savecsvdata(o,FName);

% Save sub-databases.
if opt.savesubdb && any(isSubdb)
    doSaveSubdb();
end

% Nested functions.

%**************************************************************************
    function doSaveSubdb()
        for ii = find(isSubDb)
            iiName = List{ii};
            iiFName = [Fname,'_',iiName];
            saved = dbsave(D.(iiName),iiFName,Dates,varargin{:});
            Saved{end+1} = saved;
        end
    end % doSaveSubdb().

end

% Subfunctions.

%**************************************************************************
function c = xxPrintSize(s)
% xxPrintSize  Print the size of the saved variable in the format
% 1-by-1-by-1 etc.

c = [sprintf('%g',s(1)),sprintf('-by-%g',s(2:end))];
c = ['[',c,']'];

end % xxPrintSize().