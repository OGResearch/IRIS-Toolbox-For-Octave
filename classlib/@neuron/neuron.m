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

	end
end