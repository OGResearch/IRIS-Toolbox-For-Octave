function parseMoswTrue( filename )

content = file2char(filename);

content = strrep(content,'true % ##### MOSW','false % ##### MOSW');

char2file(content,filename);

end