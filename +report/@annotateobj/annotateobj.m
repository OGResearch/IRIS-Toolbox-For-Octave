classdef annotateobj < report.genericobj
    % annotateobj  [Not a public class] Superclass for highlight and vline objects.
    %
    % Backend IRIS class.
    % No help provided.
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.
    
    properties
        location = [];
        background = NaN;
    end
    
    methods
        function this = annotateobj(varargin)
            this = this@report.genericobj(varargin{:});
            this.childof = {'graph'};
            this.default = [this.default, { ...
                'vposition','top', ...
                    @(x) (isnumericscalar(x) && x >= 0 &&  x <= 1) ...
                    || (isanychari(x,{'top','bottom','centre','center','middle'})),true,...
                'hposition','right', ...
                    @(x) isanychari(x,{'left','right','centre','center','middle'}),true,...
                'timeposition','middle', ...
                    @(x) isanychari(x,{'middle','after','before'}),true, ...
            }];
        end
        
        function [this,varargin] = specargin(this,varargin)
            if ~isempty(varargin)
                this.location = varargin{1};
                varargin(1) = [];
            end
        end
        
    end
    
end