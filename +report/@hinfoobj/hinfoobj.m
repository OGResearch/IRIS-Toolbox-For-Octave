classdef hinfoobj < handle
    % hinfoobj  [Not a public class] Report compiling and publishing info.
    %
    % Backed IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.

    
    properties
        orientation = ''; % Landscape or portrait orientation of report.
        epstopdf = Inf; % Command arguments to epstopdf.
        latexRun = 0; % Number of LaTeX compiler runs.
        tempDir = ''; % Name of temporary directory where all files are saved.
        tempFile = cell(1,0); % Master file title.
        figureHandle = zeros(1,0); % List of figure handles kept open after publishing.
        longTable = false; % Use of longtable package.
        footnote = cell(1,0); % Stack of unpublished footnotes.
        footnoteCount = 0; % Footnote running count.
    end
    
    
    methods
        
        function This = hinfoobj(varargin)
            if isempty(varargin)
                return
            end
            if length(varargin) == 1 && isa(varargin{1},'hinfoobj')
                This = varargin{1};
                return
            end
        end
        
    end
    
    
    methods
        varargout = outpstruct(varargin)
    end
    
end