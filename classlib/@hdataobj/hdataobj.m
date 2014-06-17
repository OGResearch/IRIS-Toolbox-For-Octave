classdef hdataobj < handle
    
    
    properties
        Data = [];
        Range = zeros(1,0);
        Id = cell(1,0);
        Log = false(1,0);
        
        Name = cell(1,0);
        Label = cell(1,0);
        
        Precision = 'double';
        IncludeLag = true; % Include lags of variables in output tseries.
        IncludeParam = true; % Include parameter database.
        IsVar2Std = false; % Convert variance to std dev.
        Contributions = []; % If non-empty, contains labels for contributions.
        ParamDb = struct();
    end
    
    
    methods
        varargout = hdataassign(varargin)
        varargout = hdata2tseries(varargin)
    end
    
    
    methods (Static)
        varargout = hdatafinal(varargin)
    end
    
    
    % Constructor
    %-------------
    methods
        function This = hdataobj(varargin)
            if nargin == 0
                return
            end
            if nargin == 1 && isa(varargin{1},'hdataobj')
                This = varargin{1};
                return
            end
            if nargin > 1
                
                % hdataobj(CallerObj,Range,[Size2,...],...)
                
                CallerObj = varargin{1};
                This.Range = varargin{2};
                Size = varargin{3};
                varargin(1:3) = [];
                nPer = length(This.Range);
                if isempty(Size)
                    utils.error('hdataobj:hdataobj', ...
                        'Size in second dimension not supplied.');
                end
                
                for i = 1 : 2 : length(varargin)
                    name = strrep(varargin{i},'=','');
                    This.(name) = varargin{i+1};
                end
                    
                hdatainit(CallerObj,This);
                
                for i = 1 : length(This.Id) 
                    imagId = imag(This.Id{i});
                    realId = real(This.Id{i});
                    maxLag = -min(imagId);
                    for j = find(imagId == 0)
                        name = This.Name{realId(j)};
                        This.Data.(name) = ...
                            nan([maxLag+nPer,Size], ...
                            This.Precision);
                    end
                end 
                
                if This.IncludeParam
                    This.ParamDb = addparam(CallerObj);
                end
            end
        end
    end


end