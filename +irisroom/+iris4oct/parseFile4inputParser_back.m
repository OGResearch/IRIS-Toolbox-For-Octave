function parseFile4inputParser_back( filename )

lbr = sprintf('\n');

fid = fopen(filename,'r');
tline = '';
start = '';
while isempty(strfind(tline,'inputParser('))
  tline = fgetl(fid);
  start = [start,tline,lbr];
end

vnm = regexprep(strtrim(tline),'\s*=.*','');
spos = ftell(fid);

tline = '';
while isempty(strfind(tline,[vnm '.parse(']))
  tline = fgetl(fid);
end
tline = fgetl(fid);

tline = '';
pblk = '';
while isempty(strfind(tline,[vnm '.parse(']))
  tline = fgetl(fid);
  pblk = [pblk,tline,lbr];
end
tline = fgetl(fid);

tline = '';
rest = '';
while ~feof(fid)
  tline = fgetl(fid);
  rest = [rest,lbr,tline];
end
rest = rest(2:end);

pblk_adj = regexprep(pblk,[vnm '\s*=\s*'],'');

fclose(fid);

fid = fopen(filename,'w+');

fprintf(fid,'%s%s%s',start,pblk_adj,rest);

fclose(fid);
