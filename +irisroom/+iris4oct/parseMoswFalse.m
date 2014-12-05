function parseMoswFalse( filename )

content = file2char(filename);

content = strrep(content,'false % ##### MOSW','true % ##### MOSW');

char2file(content,filename);

end