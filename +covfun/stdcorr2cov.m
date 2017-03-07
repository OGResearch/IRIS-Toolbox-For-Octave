function Omg = stdcorr2cov(stdcorr,ne)
% STDCORR2COV  [Not a public function] Convert stdcorr vector to covariance matrix.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Transpose `stdcorr` if it is a row vector, and its length matches the
% prescribed size.
if isvector(stdcorr) && size(stdcorr,1) == 1 ...
        && length(stdcorr) == ne + ne*(ne-1)/2
    stdcorr = stdcorr.';
end

%**************************************************************************

% Find positions where the stdcorr vector is equal to the previous
% position. We will simply copy the cov matrix in these position.
stdcorreq = [false,all(stdcorr(:,2:end) == stdcorr(:,1:end-1),1)];

stdonly = size(stdcorr,1) == ne;
nstdcorr = size(stdcorr,2);
if ne > 0
  pos = tril(ones(ne),-1) == 1;
else
  pos = [];
end
stdcorr(1:ne,:) = abs(stdcorr(1:ne,:));
stdvec = stdcorr(1:ne,:);

varvec = stdvec.^2;
if ~stdonly
    corrvec = stdcorr(ne+1:end,:);
    corrvec(corrvec > 1 | corrvec < -1) = NaN;
end

Omg = zeros(ne,ne,nstdcorr);
for i = 1 : nstdcorr
    if stdcorreq(i) && i > 1
        Omg(:,:,i) = Omg(:,:,i-1);
    elseif stdonly || all(corrvec(:,i) == 0)
        Omg(:,:,i) = diag(varvec(:,i));
    else
        % Create the correlation matrix.
        R = zeros(ne);
        % Fill in the lower triangle.
        R(pos) = corrvec(:,i);
        % Copy the lower triangle into the upper triangle and add ones
        % on the main diagonal.
        R = R + R.' + eye(ne);
        % Creat a matrix where the i,j-th element is std(i)*std(j).
        D = stdvec(:,i*ones(1,ne));
        D = D .* D.';
        % Multiply the i,j-th entry in the correlation matrix by
        % std(i)*std(j).
        Omg(:,:,i) = R .* D;
    end
    index = isinf(diag(Omg(:,:,i)));
    if any(index)
        Omg(index,:,i) = Inf;
        Omg(:,index,i) = Inf;
    end
end

end