function flag = ismatlab()
  flag = ~exist('OCTAVE_VERSION','builtin');
end