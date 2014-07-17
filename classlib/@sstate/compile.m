function forblocks = compile(s,outputfile,varargin)
% compile  Compile an m-file function based on a steady-state file.
%
% Syntax
% =======
%
%     compile(S)
%     compile(S,Fname,...)
%
% Input arguments
% ================
%
% * `S` [ sstate ] - Sstate object built on a steady-state file.
%
% * `Fname` [ char | empty ] - Filename of the compiled m-file function; if
% not specified or empty the original steady-state filename will be used
% with an '.m' extension.
%
% Options
% ========
%
% * `'excludeZero='` [ `true` | *`false`* ] - Automatically detect and exclude
% zero solutions in blocks that result in multiple solutions. 
%
% * `'deleteSymbolicMfiles='` [ *`true`* | `false` ] - Delete auxiliary m-files
% created to call the Symbolic Math toolbox.
%
% * `'end='` [ numeric | char | *`Inf`* ] - Compile the steady-state m-file
% function only up to this block.
%
% * `'simplify='` [ numeric | *`Inf`* ] - The minimum length for a symbolic
% expression to be simplified using the `simplify` function; Inf means no
% expressions will undergo simplification.
%
% * `'start='` [ numeric | char | *1* ] - Compile the steady-state m-file
% function starting from this block.
%
% * `'symbolic='` [ *`true`* | `false` ] - Call the Symbolic Math toolbox to
% solve blocks marked with a [`!symbolic`](sstatelang/symbolic) keyword;
% otherwise, all blocks will be solved numerically regardless of their
% specification.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    outputfile; %#ok<VUNUS>
catch
    outputfile = [];
end

if length(varargin) == 1 && isstruct(varargin{1})
   opt = varargin{1};
else
   opt = passvalopt('sstate.compile',varargin{:});
end

% Auto name for the output file.
if isempty(outputfile)
   [temppath,temptitle] = fileparts(s.FName);
   outputfile = fullfile(temppath,[temptitle,'.m']);
end

opt.outputfile = outputfile;
opt.inputfile = s.FName;
clear('functions');

%--------------------------------------------------------------------------

% Blocks to evaluate.
if ischar(opt.start)
   startIndex = find(strcmp(opt.start,s.label),1);
   if isempty(startIndex)
      utils.error('sstate', ...
         'Invalid start block: ''%s''.',opt.start);
   end
else
   startIndex = opt.start;
   if startIndex ~= round(startIndex) ...
         || startIndex < 1 || startIndex > s.nblock
      utils.error('sstate', ...
         'Invalid start block: %g.',opt.start);
   end
end
if ischar(opt.end)
   endIndex = find(strcmp(opt.end,s.label),1);
   if isempty(endIndex)
      utils.error('sstate', ...
         'Invalid end block: ''%s''.',opt.end);
   end
else
   % Use the `min` function to permit using Inf (for the last block).
   endIndex = min([opt.end,s.nblock]);
   if endIndex ~= round(endIndex) || endIndex < 1
      utils.error('sstate', ...
         'Invalid end block: %g.',opt.end);
   end
end
forblocks = startIndex : endIndex;

% Use numerical solution instead of symbolic if Symbolic Math Tbx not
% installed or if requested by user.
index = strcmp('symbolic',s.type);
if any(index) && (isempty(ver('symbolic')) || ~opt.symbolic)
   s.type(index) = {'numerical'};   
   if opt.symbolic
      warning('iris:sstate', [ ...
         '*** The Symbolic Math Tbx not installed. ', ...
         'Numerical solutions will be used instead.']);
   end
end

% Create subfunctions for each block.
subfun = cell(1,s.nblock);
for i = forblocks
   % Write subfunction heading.
   x = codecreator();
   x.printn('function varargout = block%d(varargin)',i);
   % Assign the i-th block's input values. Enclose in a try-end statement
   % so that an error is only generated when a missing input parameter is
   % really needed to evaluate the subsequent equations.
   x.autoIndent = 2;
   x.printn('% Create a variable for each input database field.');
   for j = 1 : length(s.input{i})
      x.printn('try, %s = varargin{1}.%s(varargin{2}); end', ...
         s.input{i}{j},s.input{i}{j});
   end
   x.autoIndent = 0;
   % Assign growth rates.
   %for j = 1 : length(s.growth{i})
   %     x.printn(s.growth{i}{j});
   %end
   switch s.type{i}
      case 'assignment'
         tmpcode = xxassignment(s.eqtn{i},s.solvefor{i});
         x.print(tmpcode);
      case 'growthnames2imag'
         gname = creategname(s,s.input{i});
         tmpcode = xxgrowthnames2imag(s.input{i},gname);
         x.print(tmpcode);
      case 'symbolic'
         % Solve block symbolically.
         [tmpcode,errormsg] = xxsymbolic(i, ...
            s.eqtn{i},s.solvefor{i},s.allbut,s.logs,opt);
         if ~isempty(errormsg)
            warning('iris:sstate', [...
               '\n*** Error solving symbolically block #%g.', ...
               '\n*** %s', ...
               '\n*** Block will be solved numerically.'], ...
               i,errormsg);
            tmpcode = ...
               xxnumerical(s.eqtn{i},s.solvefor{i},s.allbut,s.logs);
            s.type{i} = 'numerical';
         end   
         x.print(tmpcode);
      case 'numerical'
         % Solve block numerically.
         tmpcode = xxnumerical(s.eqtn{i},s.solvefor{i},s.allbut,s.logs);
         x.print(tmpcode);
   end
   if ~strcmp(s.type{i},'numerical')
      % Set the second and third output arguments, i.e. `discrep` and
      % `exitflag`, in non-numerical blocks.
      x.autoIndent = 2;
      x.printn('varargout{2} = [];');
      x.printn('varargout{3} = 1;');
      x.autoIndent = 0;
   end
   % Write end of subfunction.
   x.print('end');
   subfun{i} = x.Code;
end

% Grab the primary function template from the end of this file.
c = strfun.grabtext('=== START OF PRIMARY FUNCTION TEMPLATE ===', ...
   '=== END OF PRIMARY FUNCTION TEMPLATE ===');

[~,tempfname] = fileparts(s.FName);
c = strrep(c,'#fileName',tempfname);
c = strrep(c,'#FILENAME',upper(tempfname));
c = strrep(c,'#date',datestr(now()));
c = strrep(c,'#year',sprintf('%d',datevec(now())));
c = strrep(c,'#nBlock',sprintf('%d',length(forblocks)));
% Optim Tbx settings.
c = strrep(c,'#tolX',sprintf('%e',opt.tolx));
c = strrep(c,'#tolFun',sprintf('%e',opt.tolfun));
c = strrep(c,'#maxIter',sprintf('%g',opt.maxiter));
c = strrep(c,'#maxFunEvals',sprintf('%g',opt.maxfunevals));
c = strrep(c,'#display',['''',opt.display,'''']);
% List of input parameters.
inputList = strfun.cslist(s.input{1}, ...
   'wrap',75,'lead','   ','trail',' ...','quote','single');
c = strrep(c,'#input',inputList);
   
% Add block-specific subfunctions.
divider = '% $ ';
divider(end+1:75) = '*';
x = codecreator();
for i = forblocks
   x.nl();
   x.printn(divider);
   x.printn(subfun{i});
   x.printn('%% $ block%d().',i);
end
c = strrep(c,'#blocks',x.Code);

% Save ready-to-use m-file function.
char2file(c,outputfile);
rehash();

end

% Subfunctions.

%**************************************************************************
function code = xxassignment(eqtn,solvefor)
   % Write equations.
   x = codecreator();
   x.nl();
   x.printn('% ======START OF ESSENTIALS=====');
   for i = 1 : length(eqtn)
      x.printn([eqtn{i},';']);
   end
   x.printn('% ======END OF ESSENTIALS=====');
   x.nl();
   % Output LHS variables.
   x.autoIndent = 2;   
   x.printn('% Create output database.');
   x.printn('varargout{1} = varargin{1};');
   for i = 1 : length(solvefor)
      x.printn('varargout{1}.%s(1,varargin{2}) = %s;', ...
         solvefor{i},solvefor{i});
   end   
   x.autoIndent = 0;   
   code = x.Code;
end % xxassignment().

%**************************************************************************
function code = xxgrowthnames2imag(input,gname)
   x = codecreator();
   % Try to create complex numbers by adding an imaginary part based on the
   % growth name.
   x.nl();
   x.printn('% ======START OF ESSENTIALS=====');
   for i = 1 : length(input)
      x.printn('try, %s = %s + 1i*%s; end', ...
         input{i},input{i},gname{i});
   end
   x.printn('% ======END OF ESSENTIALS=====');
   x.nl();
   % Output all variables.
   x.autoIndent = 2;
   x.printn('% Create output database.');
   x.printn('varargout{1} = varargin{1};');   
   for i = 1 : length(input)
      x.printn('varargout{1}.%s(1,varargin{2}) = %s;', ...
         input{i},input{i});
   end   
   x.autoIndent = 0;
   code = x.Code;
end % xxgrowthnames2imag().

%**************************************************************************
function [code,errormsg] = ...
   xxsymbolic(block,eqtn,solvefor,allbut,logs,options)

   code = '';
   errormsg = '';
   lastwarn('','');

   nsolvefor = numel(solvefor);
   [~,ftitle] = fileparts(options.outputfile);
   fname = sprintf('%s_block%g',ftitle,block);
   positive = {};
   for i = 1 : nsolvefor
      if xxislog(solvefor{i},logs,allbut)
         positive{end+1} = solvefor{i}; %#ok<AGROW>
      end
   end
   xxsavesymbolic(block,fname,eqtn,solvefor,positive,options);
   rehash();
   try
      state = warning();
      warning('off','symbolic:solve:warnmsg3');
      x = feval(fname);
      warning(state);
      if nsolvefor == 1
         % For one equation and one unknown, the solution is not a struct but
         % directly a sym object. Set up a struct so that we can handle it the
         % same way as mutliple-equation systems.
         temp = x;
         x = struct();
         x.(solvefor{1}) = temp;
      end
   catch Error
      errormsg = strtrim(strrep(Error.message,char(10),' '));
      errormsg = sprintf('Uncle says: %s',errormsg);
   end
   if options.deletesymbolicmfiles
      delete([fname,'.m']);
   end
   if ~isempty(errormsg)
      return
   end
   lastWarning = lastwarn();
   if ~isempty(lastWarning)
      errormsg = strtrim(strrep(lastWarning,char(10),' '));
      errormsg = sprintf('Uncle says: %s',errormsg);
      return
   end

   % Number of solutions returned.
   nsol = numel(x.(solvefor{1}));

   % Convert sym solutions to char solutions.
   s = cell(1,nsol);
   for i = 1 : nsol
      s{i} = cell(1,nsolvefor);
      for j = 1 : nsolvefor
         tmp = x.(solvefor{j})(i);
         if numel(char(tmp)) >= options.simplify
            tmp = simple(horner(simple(tmp)));
         end
         s{i}{j} = char(tmp);
      end
   end

   % Exclude all-zero solutions if requested by the user.
   if nsol > 1 && options.excludezero
      remove = false(1,nsol);
      for i = 1 : nsol
         remove(i) = all(cellfun(@(x) strcmp(x,'0'),s{i}));
      end
      if any(remove)
         s(remove) = [];
         nsol = length(s);
         warning('iris:sstate', ...
            '\n*** A total of %g all-zero solution(s) discarded in block #%g.', ...
            sum(remove),block);
      end
   end

   if nsol == 0
      errormsg = sprintf( ...
         'Other than all-zero solutions not found for block #%g', ...
         block);
      return
   end

   % If there are multiple solutions, let the user choose.
   if nsol > 1
      choose = xxmultisolutions(s,solvefor,block);
   else
      choose = 1;
   end
   s = s{choose};

   x = codecreator();
   x.autoIndent = 2;
   x.iprintn('varargout{1} = varargin{1};');
   x.nl();
   x.autoIndent = 0;
   x.printn('% ======START OF ESSENTIALS=====');
   x.print(xxwritesolution(s,solvefor,'varargout{1}','(1,varargin{2})'));
   x.printn('% ======END OF ESSENTIALS=====');
   x.nl();
   
   % Return the code.
   code = x.Code;

end % xxsymbolic().

%**************************************************************************
function code = xxnumerical(eqtn,solvefor,allbut,logs)

   neqtn = length(eqtn);
   nsolvefor = length(solvefor);

   % Write initial values.
   x = codecreator();
   x.autoIndent = 2;
   x.printn('% USE OF VARARGOUT:');
   x.printn('% * varargout{1} Output database.');
   x.printn('% * varargout{2} Discrepancy between LHS and RHS from `fsolve`.');
   x.printn('% * varargout{3} Exit flag from `fsolve`.');
   x.printn('% * varargout{4} Optimised vector.');
   x.printn('varargout = cell(1,4);');
   x.printn('varargout{1} = varargin{1};');
   x.printn('varargout{4} = zeros(1,%g);',nsolvefor);
   x.autoIndent = 0;
   islog = false(1,nsolvefor);
   for i = 1 : nsolvefor
      islog(i) = xxislog(solvefor{i},logs,allbut);
      x.iprint(2,'try, ');
      if islog(i)
         x.print('varargout{4}(%g) = log(varargin{1}.%s(1,varargin{2})); ', ...
            i,solvefor{i});
      else
         x.print('varargout{4}(%g) = varargin{1}.%s(1,varargin{2}); ', ...
            i,solvefor{i});
      end
      x.print('catch, try, ');
      if islog(i)
         x.print('varargout{4}(%g) = log(varargin{1}.%s(1,varargin{2}-1)); ', ...
            i,solvefor{i});
      else
         x.print('varargout{4}(%g) = varargin{1}.%s(1,varargin{2}-1); ', ...
            i,solvefor{i});
      end   
      x.printn('end, end');
   end

   x.nl();
   x.printn('% ======START OF ESSENTIALS=====');
   x.printn('varargout{4}(isinf(varargout{4}) | isnan(varargout{4})) = 0;');
   x.printn('[varargout{4},varargout{2},varargout{3}] = ...');
   x.printn('   fsolve(@solve__,varargout{4},varargin{3});');

   % Nested function called by `fsolve`.
   x.iprintn('function varargout = solve__(varargin)');
   for i = 1 : nsolvefor
      if islog(i)
         x.iprintn(2,'%s = exp(varargin{1}(%g));',solvefor{i},i);
      else
         x.iprintn(2,'%s = varargin{1}(%g);',solvefor{i},i);
      end
   end

   % Compute discrepancies in individual equations.
   x.iprintn(2,'varargout{1} = [ ...');
   for i = 1 : neqtn
      x.iprint(3,regexprep(eqtn{i},'(.*?)=(.*)','$1-($2)'));
      x.printn('; ...');
   end
   x.iprintn(2,'];');
   
   % Write end of nested function.
   x.iprintn('end');
   x.printn('% ======END OF ESSENTIALS=====');
   x.nl();
   
   % Update the output database with the newly computed values. 
   x.printn( ...
      '% Update the output database with the newly computed values. ');
   for i = 1 : nsolvefor
      if islog(i)
         x.printn( ...
            'varargout{1}.%s(1,varargin{2}) = exp(varargout{4}(%g));', ...
            solvefor{i},i);
      else
         x.printn( ...
            'varargout{1}.%s(1,varargin{2}) = varargout{4}(%g);', ...
            solvefor{i},i);
      end
   end   
   
   code = x.Code;
   
end % xxnumerical().

%**************************************************************************
function choose = xxmultisolutions(s,solvefor,block)
%{
   html = strfun.grabtext('=== START OF HTML ===','=== END OF HTML ===');
   html = strrep(html,'### BLOCK NUMBER HERE ###',sprintf('%g',block));
%}

   nsol = length(s);
   x = codecreator();
   x.printn('Multiple solutions found for <a href="">block #%g</a>.',block);
   x.printn('Review the solutions below and choose one of them.');
   x.nl();
   for i = 1 : nsol
      %x.print('<div><div style="margin-top: 1em; font-size: large; font-weight: bold;">Solution #%g</div><pre style="font-family: Consolas,Monospace;">',i);
      x.printn('<a href="">* Solution #%g</a>',i);
      x.printn(xxwritesolution(s{i},solvefor));
   end
   x.printn('Multiple solutions found for <a href="">block #%g</a>.',block);
   x.printn('Review the solutions above and choose one of them.');
   disp(x.Code);

   %html = strrep(html,'### SOLUTIONS HERE ###',x.Code);
   %[ans,h] = web('-new');
   %set(h,'htmlText',html);

   ask = true;
   prompt = sprintf('Choose solution (1 to %g) or press Ctrl+C to quit: ',nsol);
   while ask
      choose = input(prompt);
      ask = choose ~= round(choose) || choose < 1 || choose > nsol;
   end
   % close(h);

end % xxmultisolutions().

%**************************************************************************
function code = xxwritesolution(s,solveFor,prefix,suffix)
   if nargin > 3 && ~isempty(prefix)
      prefix = [prefix,'.'];
   else
      prefix = '';
   end
   if nargin < 4
      suffix = '';
   end
   x = codecreator();
   for i = 1 : length(solveFor)
      x.printn('%s%s%s = %s;',prefix,solveFor{i},suffix,s{i});
   end
   code = x.Code;
end % xxwritesolutions().

%**************************************************************************
function xxsavesymbolic(block,fname,eqtn,solvefor,positive,options)
   x = codecreator();
   x.printn('function varargout = %s()',fname);
   x.printn(...
      '%% Symbolic steady state block #%g of |%s|.', ...
      block,options.inputfile);
   x.printn(xxtimestamp());
   if ~isempty(positive)
      x.printn(['syms ', ...
         sprintf('%s ',positive{:}), ...
         'positive;']);
   end
   x.printn('varargout{1} = solve( ...');
   for i = 1 : numel(eqtn)
      x.iprintn('''%s'', ...',eqtn{i});
   end
   for i = 1 : numel(solvefor)
      x.iprint('''%s'',',solvefor{i});
   end
   x.Code(end) = '';
   x.printn(');');
   x.printn('end');
   x.save([fname,'.m']);
end % xxsavesymbolic().

%**************************************************************************
function x = xxtimestamp()
   x = sprintf('%% Autogenerated by The IRIS Toolbox on %s.', ...
      datestr(now()));
end % timestamp().

%**************************************************************************
function flag = xxislog(name,logs,allbut)
   flag = any(strcmp(name,logs));
   if allbut
      flag = ~flag;
   end
end % xxislog().

%{
=== START OF PRIMARY FUNCTION TEMPLATE ===
function [P,SUCCESS,discrep,exitflag] = #fileName(P,varargin)
% #FILENAME  Steady-state m-file function based on `#fileName.s`.
%
% Autogenerated on #date.
%
% Syntax
% =======
%
%     [P,SUCCESS,DISCREP,EXITFLAG] = #fileName(P,...)
%
% Input arguments
% ================
%
% * `P` [ struct | model ] - Input database or model object from which the
% input parameters will be assigned.
%
% Output arguments
% =================
%
% * `P` [ struct | model ] - Output database or model object with the
% newly computed steady states.
%
% * `SUCCESS` [ `true` | `false` ] - True if all blocks in all
% parameterisations have been solved successfully.
%
% * `DISCREP` [ cell ] - Discrepancy between LHS and RHS in blocks solved
% numerially.
%
% * `EXITFLAG` [ cell ] - The Optimization Tbx exit flags for
% blocks solved numerically.
%
% Options
% ========
%
% * `'refresh='` [ *`true`* | `false` ] - If `P` is a model object, refresh
% dynamic links after the steady state is computed.
%
% See help on `fsolve` for other options available.

% -IRIS Toolbox.
% -Copyright (c) 2007-#year IRIS Solutions Team.

% Parse non-optimset options.
options = struct();
options.refresh = true;
if ~isempty(varargin)
    index = find(strcmpi(varargin(1:2:end),'refresh'));
    if ~isempty(index)
        options.refresh = varargin{index+1};
        varargin(index:index+1) = [];
    end
end

% Optim Tbx settings.
optim = optimset( ...
    'tolX',#tolX, ...
    'tolFun',#tolFun, ...
    'maxIter',#maxIter, ...
    'maxFunEvals',#maxFunEvals, ...
    'display',#display, ...
    varargin{:});

% List of input parameters.
input = { ...
#input
};

% Total number of blocks that will be solved.
nblock = #nBlock;

% If the first input argument is a model object, create an input database
% based on the model object's current parameterisation.
if isa(P,'model')
    outputformat = 'model';
    m = P;
    P = get(m,'sstateLevel');
%{
    P = struct();
    for i = 1 : length(input)
        P.(input{i}) = m.(input{i});
    end
%}
else
    outputformat = 'dbase';
end

% Get the number of alternative parameterisations.
[P,nalt] = getmaxlength_(P,input);

% Create function handles for individual blocks.
blockFunc = cell(1,nblock);
for i = 1 : nblock
    blockFunc{i} = mosw.str2func(sprintf('block%d',i));
end

% Call individual blocks.
discrep = cell(1,nblock);
exitflag = cell(1,nblock);
exitflag(:) = {nan(1,nalt)};
SUCCESS = true;
for i = 1 : nalt
    for j = 1 : nblock
        [P,discrep{i},exitflag{j}(i)] = blockFunc{j}(P,i,optim);
        SUCCESS = SUCCESS && exitflag{j}(i) > 0;
    end
end

% If the input argument was a model object, assign the newly computed
% steady states back to it. Refresh dynamic links if requested by the user.
if strcmpi(outputformat,'model')
    P = assign(m,P);
    if options.refresh
        P = refresh(P);
    end
end

end

% Subfunctions follow.

% $ ***********************************************************************
function [P,maxlength] = getmaxlength_(P,list)
% Get the number of alternative parameterisations.
    nlist = numel(list);
    n = nan(1,nlist);
    for i = 1 : nlist
        try
            P.(list{i}) = P.(list{i})(:).';
            n(i) = length(P.(list{i}));
        end
    end
    maxlength = max([1,n(~isnan(n))]);
    index = 1 : nlist;
    index(n == maxlength) = [];
    for i = index
        try
            P.(list{i}) = ...
                [P.(list{i}),P.(list{i})(end)*ones(1,maxlength-n(i))];
        end
    end
end
% $ gemaxlength_().
#blocks
=== END OF PRIMARY FUNCTION TEMPLATE ===
%}
