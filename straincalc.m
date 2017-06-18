function [ strain_v, strain_d,strain_engg] = straincalc( A )
%calculate dilational strains and distortortional strains for each element 
%   
strain_v=[];
strain_d=[];
strain_engg=[];
strain_engg = exp(A)-1;
strain_v= 1/3*sum(strain_engg(2:4, :));
n=1;
while n~=length(strain_engg)+1
    strain_d(n)= (1/(sqrt(2)))*sqrt((strain_engg(4,n)-strain_engg(3,n))^2 + (strain_engg(4,n)-strain_engg(2,n))^2 + (strain_engg(3,n)-strain_engg(2,n))^2);
    n=n+1; 
end

