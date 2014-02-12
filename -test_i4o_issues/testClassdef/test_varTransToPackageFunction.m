ts = tseries(qq(2010,1:18),randn(18,5));

try
  barcon(ts);
catch err
  close all;
  if ~isempty(strfind(err.message,'''h'' undefined near line'))
    error('expected error:: variable value did not reach package function');
  else
    rethrow(err);
  end
end
