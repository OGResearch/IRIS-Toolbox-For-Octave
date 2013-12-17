function dpk = mymse2var(dpk,tol)
% mymse2var  Convert MSE datapack to VAR datapack.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

if nargin < 2
    tol = getrealsmall('mse');
end

for i = 1 : 3
    nrow = size(dpk{i},1);
    nper = size(dpk{i},3);
    ndata = size(dpk{i},4);
    temp = dpk{i};
    dpk{i} = zeros([nrow,nper,ndata]);
    if isempty(dpk{i})
        continue
    end
    for j = 1 : nrow
        dpk{i}(j,:,:) = temp(j,j,:,:);
    end
    dpk{i}(abs(dpk{i}) <= tol) = 0;
end

end
