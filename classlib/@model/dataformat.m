function inputformat = dataformat(x,throwError)
% dataformat  [Not a public function] Determine format of input and output data.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

if ~exist('throwError','var')
   throwError = true;
end

if isempty(x)
   inputformat = 'empty';
elseif iscell(x)
   inputformat = 'dpack';
elseif isstruct(x)
   if isfield(x,'mean') && isfield(x,'std')
      inputformat = 'struct';
   elseif isfield(x,'mean_') && isfield(x,'mse_')
      inputformat = 'struct_';
   else
      inputformat = 'dbase';
   end
elseif isnumeric(x)
   inputformat = 'array';
else
   inputformat = 'unknown';
   if throwError
      error('iris:data','Invalid format of input data.');
   end
end

end
