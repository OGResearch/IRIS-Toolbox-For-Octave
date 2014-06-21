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
% The advantage of printing a PDF via EPS with Painters is to crop the
% unnecessary white margins around the graphics.
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

isRevert = false;
if is.hg2()
    isRevert = true;
    % Temporary fix for HG2. This should not be necessary in the official
    % release. Stretch the figure window a little bit to make font sizes
    % appear smaller in the final PDF.
    p = get(Fig,'position');
    switch get(Fig,'paperOrientation')
        case 'landscape'
            mult = 1.30;
        case 'portrait'
            mult = 1.55;
        otherwise
            mult = 1;
    end
    s = [p([1,2]),mult*p([3,4])];
    set(Fig,'position',s);
end

[fpath,ftit] = fileparts(File);
epsFile = fullfile(fpath,[ftit,'.eps']);
if is.matlab % ##### MOSW
    print(Fig,'-depsc','-painters',epsFile);
else
    print(Fig,'-depsc','-tight',epsFile);
end
latex.epstopdf(epsFile);

if isRevert
    set(Fig,'position',p);
end

end