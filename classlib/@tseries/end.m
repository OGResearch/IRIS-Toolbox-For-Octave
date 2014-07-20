function index = end(x,k,n)
  if k == 1
    index = x.start + size(x.data,1) - 1;
  else
    index = size(x.data,k);
  end
