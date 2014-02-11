function dpack = myalpha2xb(this,dpack)
% myalpha2xb  Convert alpha vector to xb vector.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

nx = size(this.solution{1},1);
nb = size(this.solution{7},1);
nf = nx - nb;
nalt = size(this.Assign,3);

if iscell(dpack)
   dpack = mean_(dpack);
else
   dpack.mean_ = mean_(dpack.mean_);
   if isfield(dpack,'mse_')
      dpack.mse_ = mse_(dpack.mse_);
   end
end

% Nested functions follow.

   % @ ********************************************************************
   function d = mean_(d)
      ndata = size(d{2},3);
      for iloop = 1 : ndata
         if iloop <= nalt
            U = this.solution{7}(:,:,iloop);
            %blackout = nf + find(~this.icondix(1,:,iloop));
         end
         d{2}(nf+1:end,:,iloop) = U*d{2}(nf+1:end,:,iloop);
         % Black out the initial conditions that are not required.
         %if doblackout
         %     d{2}(blackout,1,iloop) = NaN;
         %end
      end
   end
   % @ mse_().
   
   % @ ********************************************************************
   function d = mse_(d)
      ndata = size(d{2},4);
      nper = size(d{2},3);
      for iloop = 1 : ndata
         if iloop <= nalt
            U = this.solution{7}(:,:,iloop);
            Ut = U.';
            %blackout = nf + find(~this.icondix(1,:,iloop));
         end
         for t = 1 : nper
            d{2}(nf+1:end,:,t,iloop) = U*d{2}(nf+1:end,:,t,iloop);
            d{2}(:,nf+1:end,t,iloop) = d{2}(:,nf+1:end,t,iloop)*Ut;
         end
         % Black out the initial conditions that are not required.
         %if doblackout
         %     d{2}(blackout,:,1,iloop) = NaN;
         %     d{2}(:,blackout,1,iloop) = NaN;
         %end
      end
   end
   % @ mse_().

end
