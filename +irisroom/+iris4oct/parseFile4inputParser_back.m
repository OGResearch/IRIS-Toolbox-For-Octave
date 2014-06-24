function parseFile4inputParser_back( filename )

lbr = sprintf('\n');

fid = fopen(filename,'r+');
tline = '';
while isempty(strfind(tline,'inputParser('))
  tline = fgetl(fid);
end

vnm = regexprep(strtrim(tline),'\s*=.*','');
spos = ftell(fid);

tline = '';
pblk = '';
while isempty(strfind(tline,[vnm '.parse(']))
  tline = fgetl(fid);
  pblk = [pblk,tline,lbr];
end

tline = '';
rest = '';
while ~feof(fid)
  tline = fgetl(fid);
  rest = [rest,lbr,tline];
end

pblk_adj = regexprep(pblk,['(' vnm ')(\..*?\n)'],'$1 = $1$2');

fseek(fid,spos,'bof');
fprintf(fid,'if ismatlab\n%selse\n%send%s',pblk,pblk_adj,rest);


fclose(fid);