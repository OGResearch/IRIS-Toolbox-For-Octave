function excludefromlegend(h)
% excludefromlegend  [Not a public function] Exclude graphic object from legend.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

for i = h(:)'
   try %#ok<TRYNC>
      set(get(get(i,'Annotation'),'LegendInformation'),...
         'IconDisplayStyle','off');
   end
end

end
