function d = dbbloomberg(fname,varargin)
% dbbloomberg  Read daily series from a Bloomberg XLS export.

default = {...
   'dateformat','dd/mm/yyyy',@ischar,...
   'missing',NaN,@(x) (isnumeric(x) && length(x) == 1) || strcmpi(x,'last'),...
};
opt = passvalopt(default,varargin{:});

%**************************************************************************

[num,txt,raw] = xlsread(fname);

% Find positions of tickers in first row.
index = ~cellfun(@isempty,txt(1,:));

% Remove everything except first word from series names.
raw(1,index) = regexprep(raw(1,index),'[ ].*$','');
d = struct();

% Read inidividual series.
for i = find(index)
   dates = datenum(raw(4:end,i),opt.dateformat);
   dates = [dates(1)-1;dates];
   tmp = raw(3:end,i+1);
   index = cellfun(@isnumeric,tmp);
   values = nan(size(tmp));
   values(index) = cell2mat(tmp(index));
   comment = txt{2,i};
   % Fill in last observations for NaNs.
   if strcmpi(opt.missing,'last')
      index(1) = true;
      for j = find(~index(:).')
         values(j) = values(j-1);
      end
   end
   d.(raw{1,i}) = tseries(dates,values,comment);
end

end