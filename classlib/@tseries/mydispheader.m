function mydispheader(This)
% mydispheader  [Not a public function] Display header for tseries objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

tmpSize = size(This.data);
nPer = tmpSize(1);
fprintf('\t');
if isempty(This.data)
   fprintf('empty ');
end
fprintf('tseries object: %g%s\n',nPer,sprintf('-by-%g',tmpSize(2:end)));
strfun.loosespace();

end