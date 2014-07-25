function out = tempname(drc)

if false % ##### MOSW
  out = tempname(drc);
else
  out = strrep(tempname(drc),P_tmpdir,drc);
end