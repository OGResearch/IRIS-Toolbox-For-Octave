function varargout = request(action,varargin)
% request  Persistent repository for container class.

mlock();
persistent X;
if isempty(X)
   clear_();
end

%**************************************************************************

switch action
   case 'get'
      index = strcmp(X.name,varargin{1});
      if any(index)
         varargout{1} = X.data{index};
         varargout{2} = true;
      else
         varargout{1} = [];
         varargout{2} = false;
      end
   case 'set'
      index = strcmp(X.name,varargin{1});
      if any(index)
         if X.lock(index)
            varargout{1} = false;
         else
            X.data{index} = varargin{2};
            varargout{1} = true;
         end
      else
         X.name{end+1} = varargin{1};
         X.data{end+1} = varargin{2};
         X.lock(end+1) = false;
         varargout{1} = true;
      end
   case 'list'
      varargout{1} = X.name;
   case {'lock','unlock'}
      tmp = strcmp(action,'lock');
      if isempty(varargin)
         X.lock(:) = tmp;
      else
         index = findnames_(varargin);
         X.lock(index) = tmp;
      end
   case 'islocked'
      index = findnames_(varargin);
      varargout{1} = X.lock(index);
   case 'locked'
      varargout{1} = X.name(X.lock);
   case 'unlocked'
      varargout{1} = X.name(~X.lock);
   case 'clear'
      clear_();
   case 'save'
      if nargin > 1
         index = findnames_(varargin);
         x = struct();
         x.name = X.name(index);
         x.data = X.data(index);
         x.lock = X.lock(index);
         varargout{1} = x;
      else
         varargout{1} = X;
      end
   case 'load';
      index = strfun.findnames(X.name,varargin{1}.name,'[^\s,;]+');
      new = isnan(index);
      nnew = sum(new);
      X.name(end+(1:nnew)) = varargin{1}.name(new);
      X.data(end+(1:nnew)) = varargin{1}.data(new);
      X.lock(end+(1:nnew)) = varargin{1}.lock(new);
      index = index(~new);
      if any(X.lock(index))
         index = index(X.lock(index));
         container.error(1,X.name(index));
      end
      X.data(index) = varargin{1}.data(~new);
   case 'remove'
      if ~isempty(varargin)
         index = findnames_(varargin);
         X.name(index) = [];
         X.data(index) = [];
         X.lock(index) = [];
      end
   case 'count'
      varargout{1} = numel(X.name);
   case '?name'
      varargout{1} = X.name;
   case '?data'
      varargout{1} = X.data;
   case '?lock'
      varargout{1} = X.lock;
end

%********************************************************************
% Nested function findnames_().
   function index = findnames_(selection)
      index = strfun.findnames(X.name,selection,'[^\s,;]+');
      if any(isnan(index))
         container.error(2,selection(isnan(index)));
      end
   end
% End of nested function findnames_().

% Nested function clear_().
   function clear_()
      X = struct();
      X.name = cell([1,0]);
      X.data = cell([1,0]);
      X.lock = false([1,0]);
   end
% End of nested function clear_().

end
