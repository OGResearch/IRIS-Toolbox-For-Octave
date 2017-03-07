function Y = xxBetween(L,U)
Y = @() L + rand*(U - L);
end % xxBetween()