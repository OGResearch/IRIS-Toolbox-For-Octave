classdef esttime < handle
   
   properties
      startTime = NaN;
      timeString = '';
      hoursToGo = NaN;
      minsToGo = NaN;
      secsToGo = NaN;
      pctDone = NaN;
   end
   
   methods
      
      function this = esttime(varargin)
         strfun.loosespace();
         if ~isempty(varargin) && ischar(varargin{1})
            disp(varargin{1});
         end
         fprintf('Estimated time to go: ');
         this.startTime = tic();
      end
      
      function this = update(this,n)
         interTime = toc(this.startTime);
         if n < 1
            timeToGo = interTime*(1-n)/n;
            stop = false;
         else
            timeToGo = 0;
            stop = true;
         end
         hoursToGo = floor(timeToGo / 3600); %#ok<*PROP>
         minsToGo = floor((timeToGo - 3600*hoursToGo)/60);
         secsToGo = floor(timeToGo - 3600*hoursToGo - 60*minsToGo);
         pctDone = round(100*n);
         if ~(hoursToGo == this.hoursToGo ...
               && minsToGo == this.minsToGo ...
               && secsToGo == this.secsToGo ...
               && pctDone == this.pctDone)
            timeString = '';
            if hoursToGo > 0
               timeString = [timeString, ...
                  sprintf('%.0f h ',hoursToGo)];
            end
            if hoursToGo > 0 || minsToGo > 0
               timeString = [timeString, ...
                  sprintf('%2.0f min ',minsToGo)];
            end
            timeString = [timeString, ...
               sprintf('%2.0f sec ',floor(secsToGo))];
            timeString = [timeString,'(',sprintf('%.0f',pctDone),' pct done)'];
            if ~isempty(this.timeString)
               bs = sprintf('\b');
               fprintf(bs(ones([1,length(this.timeString)])));
            end
            fprintf(timeString);
            this.timeString = timeString;
            this.hoursToGo = hoursToGo;
            this.minsToGo = minsToGo;
            this.secsToGo = secsToGo;
            this.pctDone = pctDone;
         end
         if stop
            fprintf('\n');
            strfun.loosespace();
         end
      end
      
   end
   
end