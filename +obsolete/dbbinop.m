function dBase = dbbinop(primary,secondary,nameFilter,classFilter,fn,varargin)

if isempty(classFilter)
  classFilter = Inf;
end

invalid = cell([0,1]);
if isa(nameFilter,'char')
  for field = fieldnames(primary).'
    string = rexpn(field{1},nameFilter,0);
    if strcmp(field{1},string) && (any(isinf(classFilter)) || (isa(primary.(field{1}),classFilter) && isa(secondary.(field{1}),classFilter))) && isfield(secondary,field{1})
      try
        dBase.(field{1}) = feval(fn,primary.(field{1}),secondary.(field{1}),varargin{:});
      catch
        dBase.(field{1}) = NaN;
        invalid{end+1} = field{1};
      end
    end
  end
else
  if isnumeric(nameFilter) && all(isinf(nameFilter))
    nameFilter = fieldnames(primary);
  end
  for field = nameFilter(:).'
    if (any(isinf(classFilter)) || (isa(primary.(field{1}),classFilter) && isa(secondary.(field{1}),classFilter))) && isfield(primary,field{1}) && isfield(secondary,field{1})
      try
        dBase.(field{1}) = feval(fn,primary.(field{1}),secondary.(field{1}),varargin{:});
      catch
        dBase.(field{1}) = NaN;
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