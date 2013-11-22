classdef userfigureobj < report.basefigureobj
    
    properties
        savefig = [];
        figfile = '';
    end
    
    methods
        
        function This = userfigureobj(varargin)
            This = This@report.basefigureobj(varargin{:});
        end
        
        % Process class-specific input arguments.
        function [This,varargin] = specargin(This,varargin)
            % Create a saved hardcopy of the figure, and store it in binary form.
            h = varargin{1};
            varargin(1) = [];
            if ~isempty(h)
                if length(h) ~= 1 || ~ishghandle(h) ...
                        || ~strcmp(get(h,'type'),'figure')
                    utils.error('report', ...
                        ['The input argument H into a report figure must be ' ...
                        'a valid handle to a figure window.']);
                end
                This.figfile = [tempname(cd()),'.fig'];
                saveas(h,This.figfile);
                fid = fopen(This.figfile);
                This.savefig = fread(fid);
                fclose(fid);
            end
        end
        
        function This = setoptions(This,varargin)
            This = setoptions@report.basefigureobj(This,varargin{:});
        end
        
    end
    
    methods (Access=protected,Hidden)
        
        varargout = myplot(varargin)
        
    end
    
end