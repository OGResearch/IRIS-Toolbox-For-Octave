function yearly(this)
% yearly  Display tseries object one full year per row.
%
% Syntax
% =======
%
%     yearly(X)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object that will be displayed one full year
% of observations per row.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

if any(datfreq(this.start) == [0,1])
   disp(this);
else
   % Include pre-sample and post-sample periods to complete full years.
   freq = datfreq(this.start);
   startyear = dat2ypf(this.start);
   nper = size(this.data,1);
   endyear = dat2ypf(this.start+nper-1);
   this.start = datcode(freq,startyear,1);
   this.data = rangedata(this,[this.start,datcode(freq,endyear,freq)]);   
   % Call `disp` with yearly disp2d implementation.
   disp(this,'',@xxdisp2dyearly);
end

end

% Subfunctions.

%**************************************************************************
function [dates,data] = xxdisp2dyearly(start,data)
   [nper,nx] = size(data);
   freq = datfreq(start);
   nyear = nper / freq;
   data = reshape(data,[freq,nyear,nx]);
   data = permute(data,[3,1,2]);
   tmpdata = data;
   data = [];
   dates = {};
   tab = sprintf('\t');
   for i = 1 : nyear
      linestart = start + (i-1)*freq;
      lineend = linestart + freq-1;
      dates{end+1} = [ ...
         tab, ...
         strjust(dat2char(linestart)),'-', ...
         strjust(dat2char(lineend)),': ', ...
      ]; %#ok<AGROW>
      if nx > 1
         dates{end+1} = tab(ones(1,nx-1),:); %#ok<AGROW>
      end
      data = [data;tmpdata(:,:,i)]; %#ok<AGROW>
   end
   dates = char(dates);
end
% xxdisp2dyearly().