function dbase = dbunop(dbase0,nameFilter,classFilter,fn,varargin)

if isnumeric(nameFilter) && isnan(nameFilter)
  nameFilter = '.*';
end

if isempty(classFilter)
  classFilter = Inf;
end

invalid = cell([0,1]);
if isa(nameFilter,'char')
  for field = fieldnames(dbase0).'
    string = rexpn(field{1},nameFilter,0);
    if strcmp(field{1},string) && (any(isinf(classFilter)) || isa(dbase0.(field{1}),classFilter))
      try
        dbase.(field{1}) = feval(fn,dbase0.(field{1}),varargin{:});
      catch
        dbase.(field{1}) = NaN;
        invalid{end+1} = field{1};
      end
    end
  end
else
  if isnumeric(nameFilter) && all(isinf(nameFilter))
    nameFilter = fieldnames(dbase0);
  end
  for field = nameFilter(:).'
    if isfield(dbase0,field{1}) && (any(isinf(classFilter)) || isa(dbase0.(field{1}),classFilter))
      try
        dbase.(field{1}) = feval(fn,dbase0.(field{1}),varargin{:});
      catch
        dbase.(field{1}) = NaN;
        invalid{end+1} = field{1};
      end
    end
  end
end

if ~isempty(invalid)
  disp('Warning: Unable to perform the operation with the following field(s) (NaN assigned instead):');
  disp(printcell(invalid));
end

end

function prt = printcell(cellArray)

prt = '';
for i = 1 : length(cellArray)
  if isnumeric(cellArray{i})
    prt = [prt,'  ',num2str(cellArray{1,i}),''];
  else
    prt = [prt,'  ''',cellArray{1,i},''''];
  end
end
if ~isempty(prt)
  prt = prt(3:end);
end

end