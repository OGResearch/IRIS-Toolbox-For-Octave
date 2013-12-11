function utf8code = highCharCode2utf8(hcc)
  if hcc <= 255
    utf8code = hcc;
  else
    utf8code = nan(1,2);
    b = dec2bin(hcc);
    utf8code(1) = bin2dec(['110' repmat('0',1,5-length(b(1:end-6))) b(1:end-6)]);
    utf8code(2) = bin2dec(['10' b(end-5:end)]);
  end
end