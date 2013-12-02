function flag = ismatlab()
  flag = ~isempty(ver('MATLAB'));
end