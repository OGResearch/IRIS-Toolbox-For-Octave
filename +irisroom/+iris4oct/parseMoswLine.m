function parseMoswLine( filename )

content = file2char(filename);

content = regexprep(content,'(.*)( % >>>>> MOSW )(.*?)(\n.*)','$3$2$1$4');

char2file(content,filename);

end