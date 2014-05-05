classdef fragileobj
   
    properties
        offset = NaN;
        storage = cell(1,0);
        open = cell(1,0);
        close = cell(1,0);
    end
    
    methods
        
        % Constructor.
        function This = fragileobj(varargin)
            if length(varargin) >= 1
                C = varargin{1};
                varargin(1) = []; %#ok<NASGU>
                if ismatlab
                    dblC = double(C);
                else
                    dblC = char2double(C); % octave has multibyte codes, so they should be pre-transformed before max(), since highCharCode is not a vector, but one number
                    if max(dblC) > 255
                        utils.warning('highcharcode','You have used characters which are not allowed in Octave. Errors are quite likely to occur.');
                    end
                end
                This.offset = max(irisget('highcharcode'),max(dblC));
            end
        end
        
        % Destructor.
        function delete(This) %#ok<INUSD>
        end
        
        varargout = charcode(varargin)
        varargout = cleanup(varargin)      
        varargout = isempty(varargin)
        varargout = isnan(varargin)
        varargout = length(varargin)
        varargout = regexppattern(varargin)
        varargout = protectbrackets(varargin)
        varargout = protectbraces(varargin)
        varargout = protectquotes(varargin)
        varargout = restore(varargin)
    end
    
end