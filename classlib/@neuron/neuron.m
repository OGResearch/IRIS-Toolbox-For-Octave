classdef neuron
	
	properties
		ActivationFn@char = '' ;
		OutputFn@char = '' ;
		Position@double = [NaN,NaN] ;
		Weight@double = [] ;
		nAlt = NaN ;
		OutputParams = [] ;
	end
	
	methods
		
		function This = neuron(ActivationFn,OutputFn,nAlt,nInputs,Position)
			This.ActivationFn = ActivationFn ;
			This.OutputFn = OutputFn ;
			This.nAlt = nAlt ;
			This.Weight = NaN(nInputs,nAlt) ;
			This.Position = Position ;
		end
		
		function Dou = eval(This,Din,Range)
			
			switch This.ActivationFn
				case 'bias'
					Dou = 1 ;
				otherwise
					Dou = xxOutput(xxActivation(resize(Din,Range))) ;
			end
						
			function out = xxActivation(in)
				switch This.ActivationFn
					case 'linear'
						out = This.Weight'*in ;
					case 'minkovsky'
						out = norm(in-This.Weight,This.ActivationParams) ;
				end
						
			end
			function out = xxOutput(in)
				switch This.OutputFn
					case 's4'
						out = (This.OutputParams.*in)./sqrt(1+This.OutputParams.^2*in.^2) ;
					case 'logistic'
						out = 1./(1-exp(in)) ;
					case 'tanh'
						atmp = exp(-in*This.OutputParams) ;
						out = (1-atmp)/(1+atmp) ;
				end
			end
		end
	end
end