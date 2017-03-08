try
  cc = clA;
  save('clAobj.mat','cc');
catch err
  clear cc
  if ~isempty(strfind(err.message,'wrong type argument'))
    error('cannot test saveobj()/loadobj() overloading because of expected error:: failed to save an object of user-defined class');
  else
    rethrow(err);
  end
end
saved = load('clAobj.mat');
saveobjErr = [];
loadobjErr = [];

% test if saveobj works well
try
  myassert(saved.cc.dataProt,inf);
catch saveobjErr
end

% test if loadobj works well
try
  myassert(saved.cc.data,inf);
catch loadobjErr
end

fl = ~[isempty(loadobjErr),isempty(saveobjErr)];
if all(fl)
  fl = inf;
elseif all(~fl)
  fl = nan;
end
errMsg = '';
switch fl(1)
  case true
    errMsg = 'loadobj()';
  case false
    errMsg = 'saveobj()';
  case inf
    errMsg = 'Both loadobj() and saveobj()';
end

if any(fl)
  error([errMsg, ' overloading does not work!']);
end