function x = mymoving(x,window,fn)

window = window(:).';
if isempty(window)
    utils.warning('tseries', ...
        'The moving window is empty.');
    x(:) = NaN;
else
    for i = 1 : size(x,2)
        x(:,i) = feval(fn,tseries.myshift(x(:,i),window),2);
    end
end

end
