try
  c1 = {'aa','bb'};
  c2 = {'aa'};
  minus(c1,c2);
  c1-c2;
catch err
  clear c1 c2
  if ~isempty(strfind(err.message,'binary operator ''-'' not implemented'))
    error('expected error:: limited overloading of built-in classes'' methods');
  else
    rethrow(err);
  end
end