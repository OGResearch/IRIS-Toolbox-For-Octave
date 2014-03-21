function InclGraph = mycompilepdf(This,Opt)
% mycompilepdf  [Not a public function] Publish figure to PDF.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

set(This.handle,'paperType',This.options.papertype);

% Set orientation, rotation, and raise box.
if (isequal(Opt.orientation,'landscape') && ~This.options.sideways) ...
        || (isequal(Opt.orientation,'portrait') && This.options.sideways)
    orient(This.handle,'landscape');
    angle = -90;
    raise = 10;
else
    orient(This.handle,'tall');
    angle = 0;
    raise = 0;
end

% Print figure to EPSC and PDF.
graphicsName = '';
graphicsTitle = '';
doPrintFigure();

if strcmpi(This.options.figurescale,'auto')
    switch class(This.parent)
        case 'report.reportobj'
            if strcmpi(This.options.papertype,'uslegal')
                This.options.figurescale = 0.8;
            else
                This.options.figurescale = 0.85;
            end
        case 'report.alignobj'
            This.options.figurescale = 0.3;
        otherwise
            This.options.figurescale = 1;
    end
end

InclGraph = [ ...
    '\raisebox{',sprintf('%gpt',raise),'}{', ...
    '\includegraphics[', ...
    sprintf('scale=%g,angle=%g]{%s}', ...
    This.options.figurescale,angle,graphicsTitle),'}'];


% Nested functions...


%**************************************************************************
    function doPrintFigure()
        tempDir = This.hInfo.tempDir;
        % Create graphics file path and title.
        if isempty(This.options.saveas)
            graphicsName = tempname(tempDir);
            [~,graphicsTitle] = fileparts(graphicsName);
        else
            [saveAsPath,saveAsTitle] = fileparts(This.options.saveas);
            graphicsName = fullfile(tempDir,saveAsTitle);
            graphicsTitle = saveAsTitle;
        end
        % Try to print figure window to EPSC.
        try
            if ismatlab
                print(This.handle,'-depsc',graphicsName);
            else
                print(This.handle,'-depsc','-tight',graphicsName);
            end
            addtempfile(This,[graphicsName,'.eps']);            
        catch Error
            utils.error('report', ...
                ['Cannot print figure #%g to EPS file: ''%s''.\n', ...
                '\tMatlab says: %s'], ...
                double(This.handle),graphicsName,Error.message);
        end
        % Try to convert EPS to PDF.
        try
            if isequal(Opt.epstopdf,Inf)
                latex.epstopdf([graphicsName,'.eps']);
            else
                latex.epstopdf([graphicsName,'.eps'],Opt.epstopdf);
            end
            addtempfile(This,[graphicsName,'.pdf']);
        catch Error
            utils.error('report', ...
                ['Cannot convert graphics EPS to PDF: ''%s''.\n', ...
                '\tMatlab says: %s'], ...
                [graphicsName,'.eps'],Error.message);
        end
        % Save under the temporary name (which will be referred to in
        % the tex file) in the current or user-supplied directory.
        if ~isempty(This.options.saveas)
            % Use try-end because the temporary directory can be the same
            % as the current working directory, in which case `copyfile`
            % throws an error (Cannot copy or move a file or directory onto
            % itself).
            try %#ok<TRYNC>
                copyfile([graphicsName,'.eps'], ...
                    fullfile(saveAsPath,[graphicsTitle,'.eps']));
            end
            try %#ok<TRYNC>
                copyfile([graphicsName,'.pdf'], ...
                    fullfile(saveAsPath,[graphicsTitle,'.pdf']));
            end
        end
    end % doPrintFigure().

end