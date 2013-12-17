function plot(This)

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Get plot dimensions
maxH = -Inf ;
for iLayer = 1:This.nLayer
	for iNode = 1:numel(This.Neuron{iLayer})
		maxH = max(maxH,This.Neuron{iLayer}{iNode}.Position(2)) ;
	end
end

% Plot inputs
pos = linspace(1,maxH,This.nInputs+2) ;
pos = pos(2:3) ;
for iInput = 1:This.nInputs
	hold on
	scatter(0,pos(iInput),400,[.2 .7 .2],'s') ;

	% Plot connections
	for iNode = 1:This.Layout(1)
		hold on
		plot([0,This.Neuron{1}{iNode}.Position(1)],[pos(iInput),This.Neuron{1}{iNode}.Position(2)]) ;
	end
end

% Plot neurons
lb = Inf ;
ub = -Inf ;
for iLayer = 1:This.nLayer
	NN = numel(This.Neuron{iLayer}) ;
	for iNode = 1:NN
		pos = This.Neuron{iLayer}{iNode}.Position ;
		lb = min(lb,pos(2)) ;
		ub = max(ub,pos(2)) ;
		hold on
		scatter(pos(1),pos(2),200,[.1 .1 .1]) ;
		
		% Plot connections
		if iLayer<This.nLayer
			for iNext = 1:numel(This.Neuron{iLayer+1})
				hold on
				plot([iLayer,iLayer+1],[This.Neuron{iLayer}{iNode}.Position(2),This.Neuron{iLayer+1}{iNext}.Position(2)]) ;
			end
		end
	end
end

% Plot outputs
pos = linspace(1,maxH,This.nOutputs+2) ;
pos = pos(2:3) ;
for iOutput = 1:This.nOutputs
	hold on
	scatter(This.nLayer+1,pos(iOutput),400,[.7,.2,.2],'s') ;
	for iNode = 1:numel(This.Neuron{This.nLayer})
		hold on
		plot([This.nLayer,This.nLayer+1],[This.Neuron{This.nLayer}{iNode}.Position(2),pos(iOutput)]) ;
	end
end

% Set scale
set(gca,'ylim',[lb-2,ub+2]) ;
set(gca,'xlim',[-1 This.nLayer+2]) ;

end






