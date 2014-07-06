function hcc = back2highCharCode(utf8code)
  if size(utf8code,2) == 1
    hcc = utf8code;
  else
    hcc = sum((utf8code-[192 128]).*[64 1],2)';
  end
end

