function excludefromlegend(h)
% excludefromlegend  [Not a public function] Exclude graphic object from legend.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if true % ##### MOSW
    for i = h(:)'
      try %#ok<TRYNC>
          set(get(get(i,'Annotation'),'LegendInformation'),...
            'IconDisplayStyle','off');
      end
    end
else
    setappdata(h,'notInLegend',true);
end

end
