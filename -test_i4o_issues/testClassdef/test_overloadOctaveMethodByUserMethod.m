% create two quarterly time series (objects of class [tseries])
ts1 = tseries(qq(1,1):qq(2,4),1:8);
ts2 = tseries(qq(1,1):qq(2,4),8:-1:1);

% try to sum these time series, checking if plus() method of [tseries] class
% overloads regular '+' operator
try
  tsc = ts1 + ts2;
  clear ts1 ts2 tsc
catch err
  clear ts1 ts2 tsc
  if ~isempty(strfind(err.message,'binary operator ''+'' not implemented'))
    error('expected error:: plus() method of [tseries] is unable to overload Octave''s ''+'' operator');
  else
    rethrow(err);
  end
end
