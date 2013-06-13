function This = reduce(This,varargin)
% reduce  [Not a public function] Reduce algebraic expressions if possible.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(This.func)
   if isnumeric(This.args)
      % This is a number. Do nothing.
      return
   elseif islogical(This.args)
      % This is a logical index indicating a particular derivative among
      % multiple derivatives. You cannot run reduce without the second
      % input argument in that case.
      if isempty(varargin)
         % Do nothing if no reduction wrt to a k-th variable is requested.
         return
      end
      k = varargin{1};
      if k == find(This.args)
         This.func = '';
         This.args = 1;
      else
         This.func = '';
         This.args = 0;
      end
      return
   elseif ischar(This.args)
      % This is a variable name. Do nothing.
      return
   else      
      utils.error('sydney', ...
         'Cannot run reduction before differentation.');
   end
end

if strcmp(This.func,'sydney.d')
   % This is diff of an external function.
   return
end

for i = 1 : length(This.args)
    if isa(This.args{i},'sydney')
        This.args{i} = reduce(This.args{i},varargin{:});
    end
end

% Evaluate the function if all arguments are numeric.
if ~isempty(This.func) && iscell(This.args) && ~isempty(This.args)
    allNumeric = true;
    nArgs = length(This.args);
    args = cell(1,nArgs);
    for i = 1 : nArgs
        allNumeric = allNumeric ...
            && isa(This.args{i},'sydney') ...
            && isnumeric(This.args{i}.args);
        args{i} = This.args{i}.args;
    end
    if allNumeric
        try
            This.args = builtin(This.func,args{:});
            This.func = '';
        catch %#ok<CTCH>
            try %#ok<TRYNC>
                This.args = feval(This.func,args{:});
                This.func = '';
            end
        end
    end
end

switch This.func
   case 'uplus'
      doUplus();
   case 'uminus'
      doUminus();
   case 'plus'
      doPlus();
   case 'minus'
      doMinus();
   case 'times'
      doTimes();
   case 'rdivide'
      doRdivide();
   case 'power'
      doPower();
end

   function doUplus()
      if isequal(This.args{1}.args,0)
         This.func = '';
         This.args = 0;
      elseif isnumeric(This.args{1}.args)
         This.func = '';
         This.args = This.args{1}.args;
      end
   end

   function doUminus()
      if isequal(This.args{1}.args,0)
         This.func = '';
         This.args = 0;
      elseif isnumeric(This.args{1}.args)
         This.func = '';
         This.args = -This.args{1}.args;
      end
   end

   function doPlus()
      if isequal(This.args{1}.args,0)
         This = This.args{2};
      elseif isequal(This.args{2}.args,0)
         This = This.args{1};
      end
   end

   function doMinus()
      if isequal(This.args{1}.args,0)
         This.func = 'uminus';
         This.args = This.args(2);
      elseif isequal(This.args{2}.args,0)
         This = This.args{1};
      end
   end

   function doTimes()
      if isequal(This.args{1}.args,0) || isequal(This.args{2}.args,0)
         % 0*x or x*0
         This.func = '';
         This.args = 0;
         return
      end
      if isequal(This.args{1}.args,1)
         % 1*x
         This = This.args{2};
      elseif isequal(This.args{2}.args,1)
         % x*1
         This = This.args{1};
      elseif isequal(This.args{1}.args,-1)
         % (-1)*x
         This.func = 'uminus';
         This.args = This.args(2);
      elseif isequal(This.args{2}.args,-1)
         % x*(-1)
         This.func = 'uminus';
         This.args = This.args(1);
      end
   end

   function doRdivide()
      if isequal(This.args{1}.args,0)
         This.func = '';
         This.args = 0;
      elseif isequal(This.args{2}.args,1)
         This = This.args{1};
      elseif isequal(This.args{2}.args,-1)
         This.func = 'uminus';
         This.args = This.args(1);
      end
   end

   function doPower()
      if isequal(This.args{2}.args,0) || isequal(This.args{1}.args,1)
         This.func = '';
         This.args = 1;
      elseif isequal(This.args{1}.args,0)
         This.func = '';
         This.args = 0;
      elseif isequal(This.args{2}.args,1)
         This = This.args{1};
      end
   end

end