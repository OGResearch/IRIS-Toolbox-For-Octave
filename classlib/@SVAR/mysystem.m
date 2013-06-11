function [A,B,K,Omg,alt] = mysystem(this,varargin)
% mysystem  [Not a public function] SVAR system matrices.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

[A,ans,K,ans,alt] = mysystem@VAR(this,varargin{:}); %#ok<NOANS,ASGLU>

ny = size(A,1);
n3 = size(A,3);
B = this.B(:,:,alt);

% Covariance matrix of structural residuals.
varvec = this.std(alt) .^ 2;
Omg = eye(ny);
Omg = Omg(:,:,ones(1,n3));
for i = 1 : n3
    Omg(:,:,i) = Omg(:,:,i) * varvec(i);
end

end
