function disp(This)
% disp  [Not a public function] Display method for plan objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

fprintf('\tplan object: 1-by-1\n');
nx = nnzexog(This);
[nn,nnReal,nnImag] = nnzendog(This); %#ok<ASGLU>
nc = nnzcond(This);
nq = nnznonlin(This);
fprintf('\trange: %s to %s\n', ...
    dat2char(This.startDate),dat2char(This.endDate));
fprintf('\t#exogenised data points: %g\n',nx);
fprintf('\t#endogenised data points [real imag]: %g %g\n', ...
    nnReal,nnImag);
fprintf('\t#conditioning data points: %g\n',nc);
fprintf('\t#non-linearised data points: %g\n',nq);

disp@userdataobj(This);
disp(' ');

end
