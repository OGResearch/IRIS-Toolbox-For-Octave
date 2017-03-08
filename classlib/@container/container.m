classdef container
    
    methods
        
        function This = container(varargin)
            if nargin == 1
                if isa(This,'container')
                    This = varargin{1};
                end
            end
        end
        
        function x = list(This) %#ok<MANU>
            x = container.request('list');
        end
        
        function lock(This,varargin) %#ok<INUSL>
            container.request('lock',varargin{:});
        end
        
        function unlock(This,varargin) %#ok<INUSL>
            container.request('unlock',varargin{:});
        end
        
        function Flag = islocked(This,varargin) %#ok<INUSL>
            Flag = container.request('islocked',varargin{:});
        end
        
        function List = locked(This) %#ok<MANU>
            List = container.request('locked');
        end
        
        function List = unlocked(This) %#ok<MANU>
            List = container.request('unlocked');
        end
        
        function This = remove(This,varargin)
            container.request('remove',varargin{:});
        end
        
        function This = clear(This)
            container.request('clear');
            munlock('container.request');
        end
        
        function X = saveobj(This) %#ok<MANU>
            X = container.request('save');
        end
        
        function varargout = get(This,varargin)
            if ~isempty(varargin)
                [varargout{1},flag] = container.request('get',varargin{1});
                if ~flag
                    container.error(2,varargin{1});
                end
                [varargout{2:length(varargin)}] = get(This,varargin{2:end});
            end
        end
        
        function This = put(This,varargin)
            if ~isempty(varargin)
                pp = inputParser();
                pp.addRequired('c',@(x) isa(x,'container'));
                pp.addRequired('name',@ischar);
                pp.parse(This,varargin{1});

                if ~isempty(varargin)
                    flag = container.request('set',varargin{1},varargin{2});
                    if ~flag
                        container.error(1,varargin{1});
                    end
                    This = put(This,varargin{3:end});
                end
            end
        end
        
        function disp(This) %#ok<MANU>
            list = container.request('list');
            if false % ##### MOSW
                status = get(0,'formatSpacing');
            end
            fprintf('\tcontainer object: 1-by-1\n');
            if false % ##### MOSW
                set(0,'formatSpacing','compact');
            end
            
            disp(list);
            if false % ##### MOSW
                set(0,'formatSpacing',status);
            end
        end
        
        function display(This)
            if isequal(get(0,'FormatSpacing'),'compact')
                disp([inputname(1),' =']);
            else
                disp(' ')
                disp([inputname(1),' =']);
                disp(' ');
            end
            disp(This);
        end
        
    end
    
    methods (Static)
        
        function This = loadobj(This)
            container.request('load',This);
            This = container();
        end
        
    end
    
    methods (Static,Access=private)
        
        varargout = request(Action,varargin)
        
        function error(Code,List,varargin)
            switch Code
                case 1
                    msg = ['Cannot re-write container entry ''%s''. ', ...
                        'This entry is locked.'];
                case 2
                    msg = 'Reference to non-existent container entry: ''%s''.';
            end
            if nargin == 1
                List = {};
            elseif ~iscell(List)
                List = {List};
            end
            utils.error('container',msg,List{:});
        end
    end
    
end