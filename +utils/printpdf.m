function printpdf(FILENAME)

[fpath,ftit] = fileparts(FILENAME);
epsname = fullfile(fpath,[ftit,'.eps']);
print('-depsc',epsname);
latex.epstopdf(epsname);
delete(epsname);

end