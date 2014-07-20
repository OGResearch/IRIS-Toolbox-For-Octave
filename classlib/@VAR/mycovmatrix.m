function Cov = mycovmatrix(This,Alt)

try
    Alt; %#ok<VUNUS>
catch
    Alt = ':';
end

%--------------------------------------------------------------------------

Cov = This.Omega(:,:,Alt);

end