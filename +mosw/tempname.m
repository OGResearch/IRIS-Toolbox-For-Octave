function out = tempname(drc)

if true % ##### MOSW
  out = tempname(drc);
else
  out = strrep(tempname(drc),P_tmpdir,drc);
end