function [Close,Inside,ThisLevel] = matchbrk(C,Open,Fill)
% matchbrk  Match an opening bracket found at the beginning of char string.
%
% Syntax
% =======
%
%     [Close,Inside,ThisLevel] = strfun.matchbrk(Text)
%     [Close,Inside,ThisLevel] = strfun.matchbrk(Text,Open)
%     [Close,Inside,ThisLevel] = strfun.matchbrk(Text,Open,Fill)
%
% Input arguments
% ================
%
% * `Text` [ char ] - Text string.
%
% * `Open` [ numeric ] - Position of the requested opening bracket; if not
% specified the opening bracket is assumed at the beginning of `Text`.
%
% * `Fill` [ char ] - Auxiliary character that will be used to replace the
% content of nested brackets in `ThisLevel`; if not specified `Fill` is a
% white space, `' '`.
%
% Output arguments
% =================
%
% * `Close` [ numeric ] - Position of the matching closing bracket.
%
% * `Inside` [ char ] - Text string inside the matching brackets.
%
% * `ThisLevel` [ char ] - Text string inside the matching brackets where
% nested brackets are replaced with `Fill`.
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    Open; %#ok<*VUNUS>
catch %#ok<*CTCH>
    Open = 1;
end


try
    Fill;
catch
    Fill = ' ';
end

% Parse input arguments.
pp = inputParser();
if ismatlab
pp.addRequired('Text',@ischar);
pp.addRequired('Open',@is.numericscalar);
pp.addRequired('Fill',@(x) ischar(x) && length(x) == 1);
pp.parse(C,Open,Fill);
else
pp = pp.addRequired('Text',@ischar);
pp = pp.addRequired('Open',@is.numericscalar);
pp = pp.addRequired('Fill',@(x) ischar(x) && length(x) == 1);
pp = pp.parse(C,Open,Fill);
end

Close = [];
Inside = '';
ThisLevel = '';

if Open > length(C)
   return
end

%--------------------------------------------------------------------------

C = C(:).';
openBrk = C(Open);
switch openBrk
   case '('
      closeBrk = ')';
   case '['
      closeBrk = ']';
   case '{'
      closeBrk = '}';
   case '<'
      closeBrk = '>';
   otherwise
      return
end

% Find out the positions of opening and closing brackets.
x = zeros(size(C));
x(C == openBrk) = 1;
x(C == closeBrk) = -1;
x(1:Open-1) = NaN;
% Assign the level numbers to the content of nested brackets. The closing
% brackets have always the level number of the outside content.
cumX = x;
cumX(Open:end) = cumsum(x(Open:end));
Close = find(cumX == 0,1,'first');
if nargout > 1
   if ~isempty(Close)
      Inside = C(Open+1:Close-1);
      if ~isempty(Inside)
         x = x(Open+1:Close-1);
         cumX = cumX(Open+1:Close-1);
         ThisLevel = Inside;
         % Replace the content of higher-level nested brackets with `Fill`.
         ThisLevel(cumX > cumX(1)) = Fill;
         % Replace also the closing higher-level brackets (they are not
         % captured above).
         ThisLevel(x == -1) = Fill;
      else
         ThisLevel = '';
      end
   end
end

end