try
  strTestVar = num2str(123,'');
  if exist('strTestVar','var')
    clear strTestVar
    error('my_err_identifier');
  end
catch err
  clear strTestVar
  if ~isempty(strfind(err.message,'my_err_identifier'))
    error('expected error:: Octave didn''t crash when empty format string provided for num2str()');
  else
    rethrow(err);
  end
end
