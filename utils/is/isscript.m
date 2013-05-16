function flag = isscript(file)
% isscript  True if file is an m-file script.

[fpath,ftitle,fext] = fileparts(file);
if ~strcmpi(fext,'.m')
   flag = false;
   return
end

x = file2char(file);
x = strfun.removecomments(x,{'%{','%}'},'%','\.\.\.');
flag = isempty(regexp(x,'^\s*function','once'));

end