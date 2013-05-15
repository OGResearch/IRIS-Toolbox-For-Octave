function C = acovfsmp(x,options)
% ACOVFSMP  [Not a public function] Sample autocovariance function.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

xsize = size(x);
x = x(:,:,:);
[nper,nx,nloop] = size(x);

if isinf(options.order)
    options.order = nper - 1;
end

if options.demean
    x = bsxfun(@minus,x,mean(x,1));
end

C = zeros(nx,nx,1+options.order,nloop);
for iloop = 1 : nloop
    xi = x(:,:,iloop);
    xit = xi.';
	if options.smallsample
		T = nper-1;
	else
		T = nper;
	end
    C(:,:,1,iloop) = xit*xi / T;
    for i = 1 : options.order
        if options.smallsample
            T = T - 1;
        end
        C(:,:,i+1,iloop) = xit(:,1:end-i)*xi(1+i:end,:) / T;
    end
end

if length(xsize) > 3
    C = reshape(C,[nx,nx,1+options.order,xsize(3:end)]);
end

end