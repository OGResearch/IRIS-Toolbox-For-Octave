function parseFile4isPackage( filename )

lbr = sprintf('\n');

fid = fopen(filename,'r');
tline = '';
newfile = '';
while ~feof(fid)
  tline = fgetl(fid);
  if ~isempty(strfind(tline,'@is.'))
    tline = regexprep(tline,'@is.(\w+)','@(isArg)is.$1(isArg)');
  end
  newfile = [newfile,tline,lbr];
end
fclose(fid);

fid = fopen(filename,'w+');
newfile(end) = '';
fwrite(fid,newfile,'char');
fclose(fid);