classdef sstate < userdataobj & getsetobj
    % sstate  Steady-state objects and functions.
    %
    % You can create a steady-state (sstate) object by loading a steady-state
    % (sstate) file. The sstate object can be then saved as a stand-alone
    % m-file function and repeatedly solved for different parameterisations.
    %
    % Sstate methods:
    %
    % Constructor
    % ============
    %
    % * [`sstate`](sstate/sstate) - Create new steady-state object based on sstate file.
    %
    % Compiling stand-alone m-file functions
    % =======================================
    %
    % * [`compile`](sstate/compile) - Compile an m-file function based on a steady-state file.
    %
    % Running stand-alone sstate m-file functions
    % ============================================
    %
    % * [`standalonemfile`](sstate/standalonemfile) - Run a compiled stand-alone sstate m-file function.
    %
    % Getting on-line help on sstate functions
    % =========================================
    %
    %     help sstate
    %     help sstate/function_name
    %
    
    % -IRIS Toolbox.
    % -Copyright (c) 2007-2013 IRIS Solutions Team.
    
    % TODO: Pass in parameters when constructing sstate to enable using
    % !if..!else..!end and !switch..!case..!end.
    
    properties
        fname = '';
        Export = {};
        type = cell([1,0]);
        input = cell([1,0]);
        eqtn = cell([1,0]);
        solvefor = cell([1,0]);
        logs = cell([1,0]);
        allbut = false;
        growth = cell([1,0]);
        growthnames = [];
        label = cell([1,0]);
    end
    
    properties (Dependent,Hidden)
        nblock
    end
    
    methods
        
        function This = sstate(InpFile,varargin)
            % sstate  Create new steady-state object based on sstate file.
            %
            % Syntax
            % =======
            %
            %     S = sstate(File,...)
            %
            % Input arguments
            % ================
            %
            % * `File` [ char ] - Name of the steady-state file that will
            % loaded and converted to a new sstate object.
            %
            % Output arguments
            % =================
            %
            % * `S` [ sstate ] - New sstate object based on the input steady-state
            % file.
            %
            % Options
            % ========
            %
            % * `'assign='` [ struct | *empty* ] - Database that will used by the
            % preparser to evaluate conditions and expressions in the `!if` and
            % `!switch` structures.
            %
            % Description
            % ============
            %
            % Example
            % ========
            %
            
            % -IRIS Toolbox.
            % -Copyright (c) 2007-2013 IRIS Solutions Team.
            
            This = This@userdataobj();
            if nargin == 0
                return
            end
            opt = passvalopt('sstate.sstate',varargin{:});
            This.fname = InpFile;
            % Preparse sstate file.
            p = preparser(This.fname, ...
                'assign',opt.assign,'saveas',opt.saveas);
            % Parse sstate code.
            This = parse(This,p);
            % Get and save carry-around files.
            This.Export = p.Export;
            export(This);
        end
        
        varargout = get(varargin)
        varargout = compile(this,varargin)
        
        function flag = isempty(this)
            flag = isempty(this.type);
        end
        
        function n = get.nblock(this)
            n = numel(this.type);
        end
        
    end
    
    methods (Hidden)
        
        function disp(this)
            if isempty(this)
                fprintf('\tempty sstate object\n');
            else
                fprintf('\tsstate object: %g block(s)\n',this.nblock);
            end
            disp@userdataobj(this);
            disp(' ');
        end
        
        function gname = creategname(this,name)
            if ischar(name)
                returnChar = true;
                name = {name};
            else
                returnChar = false;
            end
            gname = name;
            if ischar(this.growthnames)
                % Plain template.
                for i = 1 : length(name)
                    gname{i} = strrep(this.growthnames,'?',name{i});
                end
            else
                % Function handle.
                for i = 1 : length(name)
                    gname{i} = this.growthnames(name{i});
                end
            end
            if returnChar
                gname = gname{1};
            end
        end
        
        function export(this)
            preparser.export(this,this.Export);
        end
        
        varargout = parse(varargin)
        
    end
    
    methods (Static,Hidden)
        
        function Invalid = chkreserved(Eqtn,SolveFor)
            % Check the list of variables that are solved for symbolically for
            % MuPAD reserved words.
            reserved = { ...
                'E','I','D','O', ...
                'beta','zeta','theta','psi','gamma', ...
                'Ci','Si','Ei', ...
                };
            nreserved = numel(reserved);
            found = false([1,nreserved]);
            for i = 1 : nreserved
                tmp = regexp([Eqtn,SolveFor],['\<',reserved{i},'\>'],'once');
                if any(~cellfun(@isempty,tmp))
                    found(i) = true;
                end
            end
            Invalid = reserved(found);
        end
        
        varargout = error(varargin)
        varargout = template(varargin)
        
    end
    
end