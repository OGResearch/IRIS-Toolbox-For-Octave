function flag = iswarning(component)

aux = warning('query',sprintf('iris:%s',component));
flag = strcmp(aux.state,'on');

end