function eviewsdb2irisdb(inputname,outputname,freq)

freqletters = irisget('freqletters');

  switch freq
  case 0
    freqstring = '';
  case 1
    freqstring = freqletters(1);
  case 2
    freqstring = freqletters(2);
  case 4
    freqstring = freqletters(3);
  case 6
    freqstring = freqletters(4);
  case 12
    freqstring = freqletters(5);
  otherwise
    freqstring = '?';
  end

c = file2char(inputname);
c = regexprep(c,'(\d*):(\d*)(:\d*)?',['$1',freqstring,'$2']);
c = regexprep(c,'^OBS,',',');
char2file(c,outputname);

end