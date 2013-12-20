function utf8code = highCharCode2utf8(hcc)
  if hcc <= 255 % octave's max char*1 code is 255
    utf8code = hcc;
  else
    utf8code = [fix(hcc/64) rem(hcc,64)] + [192 128];
  end
end
