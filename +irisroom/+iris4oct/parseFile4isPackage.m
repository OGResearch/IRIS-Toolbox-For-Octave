function parseFile4isPackage( filename )

lbr = sprintf('\r\n');

fid = fopen(filename,'r');
tline = '';
newfile = '';
found = false;
while ~feof(fid)
    tline = fgetl(fid);
    if ~isempty(strfind(tline,'@is.'))
        tline = regexprep(tline,'@is.(\w+)','@(varargin)is.$1(varargin{:})');
        found = true;
    end
    newfile = [newfile,tline];
    if ~feof(fid)
        newfile = [newfile,lbr];
    end
end
fclose(fid);

if found
    fid = fopen(filename,'w+');
    fwrite(fid,newfile,'char');
    fclose(fid);
end