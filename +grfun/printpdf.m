function printpdf(varargin)
% printpdf  Print figure window to PDF via EPS.
%
% Syntax
% =======
%
%     printpdf(FileName)
%     printpdf(Fig,FileName)
%
% Input arguments
% ================
%
% * `FileName` [ char ] - File name (without extension) to which the figure
% window will be printed in PDF format.
%
% * `Fig` [ handle ] - Figure window that will be printed to PDF.
%
% Description
% ============
%
% The function `printpdf` prints a figure window to a PDF by first creating
% a color EPS file and then using the `epstopdf` utility to convert the EPS
% to the final PDF. The Painters renderer is used in the Matlab `print`
% command.
%
% Example
% ========
%
%     plot(rand(15));
%     printpdf('myfigure');
%

% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if numel(varargin{1}) == 1 && ishandle(varargin{1})
    Fig = varargin{1};
    varargin(1) = [];
else
    Fig = gcf();
end
   
File = varargin{1};

%--------------------------------------------------------------------------

[fpath,ftit] = fileparts(File);
epsFile = fullfile(fpath,[ftit,'.eps']);
if true % ##### MOSW
    print(Fig,'-depsc','-painters',epsFile);
else
    if ispc
        print(Fig,'-depsc',epsFile);
    else
        print(Fig,'-depsc','-tight',epsFile);
    end
end
latex.epstopdf(epsFile);

end
