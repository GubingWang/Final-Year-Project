E_mean = 3;
E_array=[];
while i~=5
    E_array=[E_array, E_mean];
    E_mean = i+1; 
    i=i+1;
end
% plot (x,y);
% title ('Youngs modulus change with iteration');
% xlabel('iteration');
% ylabel('Youngs modulus (MPa)');
