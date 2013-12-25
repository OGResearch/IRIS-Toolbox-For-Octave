function plot(This,varargin)

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

options = passvalopt('nnet.plot',varargin{:}) ;

% Get plot dimensions
maxH = max(This.Layout)+max(This.Bias) ;
shf = -0.1 ;

% Get colour space
switch options.Color
    case 'activation'
        lc = min(abs(get(This,'activation'))) ;
        mc = max(abs(get(This,'activation'))) ;
end

% Plot inputs
pos = linspace(1,maxH,This.nInputs+2) ;
pos = pos(2:3) ;
for iInput = 1:This.nInputs
    hold on
    scatter(0,pos(iInput),400,[.2 .7 .2],'s','filled') ;
    text(-1,pos(iInput),xxFixText(This.Inputs{iInput})) ;
    
    % Plot connections
    for iNode = 1:This.Layout(1)
        switch options.Color
            case 'activation'
                color = xxColor(This.Neuron{1}{iNode}.ActivationParams(iInput)) ;
            otherwise
                color = [.1 .1 .8] ;
        end
        hold on
        plot([0,This.Neuron{1}{iNode}.Position(1)],[pos(iInput),This.Neuron{1}{iNode}.Position(2)],'Color',color) ;
    end
end
text(shf,-1,'Inputs') ;

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
        if iNode == NN && This.Bias(iLayer)
            color = [.3 .5 .9] ;
        else
            color = [.3 .3 .3] ;
        end
        scatter(pos(1),pos(2),100,color,'filled') ;
        
        % Plot connections
        if iLayer<This.nLayer
            if This.Bias(iLayer+1)
                NN2 = numel(This.Neuron{iLayer+1})-1 ;
            else
                NN2 = numel(This.Neuron{iLayer+1}) ;
            end
            for iNext = 1:NN2
                switch options.Color
                    case 'activation'
                        color = xxColor(This.Neuron{iLayer+1}{iNext}.ActivationParams(iNode)) ;
                    otherwise
                        color = [.1 .1 .8] ;
                end
                hold on
                plot([iLayer,iLayer+1],[This.Neuron{iLayer}{iNode}.Position(2),This.Neuron{iLayer+1}{iNext}.Position(2)],'Color',color) ;
            end
        end
    end
    text(iLayer+shf,-1,sprintf('Layer %g',iLayer)) ;
end

% Plot outputs
pos = linspace(1,maxH,This.nOutputs+2) ;
pos = pos(2:3) ;
for iOutput = 1:This.nOutputs
    hold on
    scatter(This.nLayer+1,pos(iOutput),400,[.7,.2,.2],'s','filled') ;
    text(This.nLayer+2,pos(iOutput),xxFixText(This.Outputs{iOutput})) ;
    for iNode = 1:numel(This.Neuron{This.nLayer})
        hold on
        plot([This.nLayer,This.nLayer+1],[This.Neuron{This.nLayer}{iNode}.Position(2),pos(iOutput)]) ;
    end
end
text(This.nLayer+1+shf,-1,'Outputs') ;

% Set scale
set(gca,'ylim',[lb-4,ub+2]) ;
set(gca,'xlim',[-2 This.nLayer+3]) ;
hold off

    function out = xxFixText(in)
        out = regexprep(in,'\{','_\{') ;
    end

    function out = xxColor(in)
        in = abs(in) ;
        out = [0 0 1-((in-lc)/(mc-lc))^2] ;
    end

end






