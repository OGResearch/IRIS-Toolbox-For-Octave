function D = dbfred(FileName,SheetName)

%--------------------------------------------------------------------------

% Read raw excel file into cell array.
[~,~,sheet] = xlsread(FileName,SheetName,'','basic');

% Extract years and months from date column.
dateCol = sheet(2:end,1);
dateCol = sprintf('%s|',dateCol{:});
tmp = regexp(dateCol,'(?<day>\d+)/(?<month>\d+)/(?<year>\d+)|','names');
month = str2num(['[',sprintf('%s,',tmp.month),']']); %#ok<ST2NM>
year = str2num(['[',sprintf('%s,',tmp.year),']']); %#ok<ST2NM>

% Determine periodicity of time series.
if all(month == 1 | month == 4 | month == 7 | month == 10)
   freq = 4;
   per = (month+2)/3;
elseif all(month == 1)
   freq = 1;
   per = month;
else
   freq = 12;
   per = month;
end

% Create IRIS serial date numbers.
dates = datcode(freq,year,per);

% Process series in columns one by one.
D = struct();
sheet(1,:) = strtrim(sheet(1,:));
for i = 2 : size(sheet,2)
   if isempty(sheet{1,i})
      continue
   end
   name = sheet{1,i};
   try
      data = cell2mat(sheet(2:end,i));
      D.(name) = tseries(dates,data);
   catch %#ok<CTCH>
      warning('Cannot convert column ''%s'' into a time series.',name);
   end
end

end
