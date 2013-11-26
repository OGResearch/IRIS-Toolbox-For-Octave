classdef eventData < event.EventData

   properties
      data
   end

   methods
      function This = eventData(x)
         This.data = x;
      end
   end
   
end