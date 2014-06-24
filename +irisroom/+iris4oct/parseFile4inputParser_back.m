function parseFile4inputParser_back( filename )

lbr = sprintf('\r\n');

fid = fopen(filename,'r');
tline = '';
start = '';
while isempty(strfind(tline,'inputParser('))
  tline = fgetl(fid);
  start = [start,tline,lbr];
  if feof(fid)
      return
  end
end

vnm = regexprep(strtrim(tline),'\s*=.*','');

tline = '';
noparse = false;
while isempty(strfind(tline,[vnm '.parse(']))
  tline = fgetl(fid);
  if ~isempty(strfind(tline,'else'))
      noparse = true;
      warning('There''s no p.parse() in %s',filename);
      break
  end
end
if ~noparse
    tline = fgetl(fid);
end

tline = '';
pblk = '';
while isempty(strfind(tline,[vnm '.parse(']))
  tline = fgetl(fid);
  if noparse && ~isempty(strfind(tline,'end'))
      break
  end
  pblk = [pblk,tline,lbr];
end
if ~noparse
    tline = fgetl(fid);
end

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
