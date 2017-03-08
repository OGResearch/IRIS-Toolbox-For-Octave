% simple case
xx = tpkg.clB();
try
    xx.dprop1;
catch err
  if ~isempty(strfind(err.message,'class not found: clB'))
    error('expected error:: octave cannot work with dependent options if class belongs to a package');
  else
    rethrow(err);
  end
end

% more complicated case
zz = tpkg.clC();
zz.dprop2;
zz.callMe(); % the way it is used in iristoolbox
