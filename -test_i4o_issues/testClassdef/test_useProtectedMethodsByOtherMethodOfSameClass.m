% create quarterly time series (object of class [tseries])
ts1 = tseries(qq(1,1):qq(2,4),1:8);

% check if methods with protected access can be called from within other methods
% of the same class
try
  disp(ts1);
  clear ts1
catch err
  clear ts1
  if ~isempty(strfind(err.message,'method `dispcomment'' has protected access'))
    error('expected error:: protected method can''t be used within other methods of this class');
  else
    rethrow(err);
  end
end
