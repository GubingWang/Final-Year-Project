%this code is used to run FE model, do fuzzy logics calculation, update
%young's Modulus,poission's Ratio and mass density of the callus
%make sure you have the correct dat file and make sure change them to "callusform5_job1"
close all
clc
clear
%Young's modulus of each tissue type
E_b=4000; %MPa
E_c=200;
E_t=3;

%poissons's ratio of each tissue type
v_b=0.36;
v_c=0.45;
v_t=0.30;

%density of each tissue type (no influence on static model, but will for dynamic model)
p_b=1.85*10^-6;%kg/mm^3
p_c=1*10^-6;
p_t=0.5*10^-6;

%create a reference table for all the elements
%update the dat file to include material properties for each element in the
%callus, so the material properties of each element can be changed
%individually
%create the contact matrix to indicate which element is connected to which
%in the callus
[REF_TABLE,elements,Datfile,fname,ContactMatrix]=MultiplyDatFile;
[~,no_of_elements]=size(REF_TABLE);

%open fuzzy logics
strainfuzzylogic = readfis('strainfuzzylogic');
%declare variables
%preallocate the array to save time
E_array=zeros(1,80);
v_array=zeros(1,80);
p_array=zeros(1,80);
IFM_array=zeros(1,80);
density_b_mean=0;
density_c_mean=0;
density_t_mean=0;
E_mean=3;
v_mean=0.3;
p_mean=0.5*10^-6;
ii=1;
spring_disp=0;
spring_load=0;
disp_array=zeros(1,80);
load_array=zeros(1,80);
density_b_array=zeros(1,80);
density_c_array=zeros(1,80);
density_t_array=zeros(1,80);

while (ii < 81) %days displayed on the plot will be ii-2, as it starts from day 0
    i=1; %counter
    m=1;
    j=1;
    
    strain_log =[];
    change_b=zeros(1,no_of_elements);
    change_c=zeros(1,no_of_elements);
    E_array(ii)=E_mean;
    v_array(ii)=v_mean;
    p_array(ii)=p_mean;
    IFM=0;
    
    if ii==1
        %initial conditions for each element
        density_t=100*ones(1,no_of_elements); %percentage
        density_b=zeros(1,no_of_elements); %percentage
        density_c=zeros(1,no_of_elements); %percentage
        %initial averaged conditions for the callus
        density_b_mean = mean(density_b);
        density_b_array(ii)= density_b_mean;
        density_c_mean = mean (density_c);
        density_c_array(ii)= density_c_mean;
        density_t_mean = mean (density_t);
        density_t_array(ii) = density_t_mean;
        IFM=0; %interfragmentary movement
        spring_disp=0;
        spring_load=0;
        IFM_array(ii)=IFM;
        disp_array(ii)=spring_disp;
        load_array(ii)=spring_load;
    else
        %read in density from the txt file created in the previous
        %iteration
        fileID = fopen ('density_c.txt','r');
        formatSpec = '%f';
        size=[1 Inf];
        density_c=fscanf(fileID, formatSpec, size);
        fclose(fileID);
        
        fileID = fopen ('density_b.txt','r');
        density_b=fscanf(fileID, formatSpec, size);
        fclose(fileID);
        
        fileID = fopen ('density_t.txt','r');
        density_t=fscanf(fileID, formatSpec, size);
        fclose(fileID);
    end
    
    %break when young's modulus converges
    %     if (ii>2)&&((E_array(ii-1)-E_array(ii-2))<0.2)
    %         break
    %     end
    
   
    %Run FEA 
    system('C:\Users\gw1012\4thYearProject\matlab\CallusForm5\Run.bat');
    iteration_string=num2str(ii);
    iteration_string=strcat('C:\Users\gw1012\4thYearProject\matlab\CallusForm5\Results_files\',iteration_string,'.t16');
    movefile('C:\Users\gw1012\4thYearProject\matlab\CallusForm5\Results_files\callusform5_job1.t16',iteration_string);%source then destimation
    
    %read principal logarithmic strain
    fileID = fopen ('output.txt','r');
    formatSpec = '%f';
    sizeA=[no_of_elements Inf];
    A=fscanf(fileID, formatSpec, sizeA);
    A=A';
    fclose(fileID);
    
    %read IFM and bone load
    fileID = fopen ('outputSPRING.txt','r');
    formatSpec = '%f';
    sizeS=[2 Inf];
    S=fscanf(fileID, formatSpec, sizeS);
    S=S';
    fclose(fileID);
    spring_disp= S(1); %mm
    spring_load= S(2); %N
    disp_array(ii)=spring_disp;%IFM
    load_array(ii)=spring_load;%bone load
    
    %calculate strains for each element
    [strain_v, strain_d,strain_engg] = straincalc( A );
    
    %determine density change of bone and cartilage using fuzzy logic
    density_change=[];
    while m<no_of_elements+1
        density_change = [density_change, evalfis([strain_v(m), strain_d(m), density_b(m), density_c(m)], strainfuzzylogic)];
        m=m+1;
    end
    
    %separate density change of bone and cartilage in the matrix
    l=length(density_change);
    density_change_ele = reshape(density_change, 2, l/2);
    
    %if the element is not in contact with bone (element having bone concentration higher than 50%),
    %its bone concentration will not change
    while j<no_of_elements+1
        if sum(ContactMatrix(j+1,:)==3)==0
            density_change_ele(1,j)=0;
        end
        change_b(j)=density_change_ele(1,j);
        change_c(j)=density_change_ele(2,j);
        j=j+1;
    end
    
    %calculate new density for each element
    for nn=1:no_of_elements
        density_b(nn)=density_b(nn)+change_b(nn);
        density_c(nn)=density_c(nn)+change_c(nn);
        density_t(nn)=100-density_b(nn)-density_c(nn);
        if (density_b(nn)>0)&&(density_c(nn)<=0)&&(density_t(nn)<=0)
            density_b(nn)=100;
            density_t(nn)=0;
            density_c(nn)=0;
        elseif(density_b(nn)>0)&&(density_c(nn)<=0)&&(density_t(nn)>0)
            density_c(nn)=0;
            density_t(nn)=100-density_b(nn);
%             if (100-density_b(nn))<0
%                 density_b(nn)=100-density_t(nn);
%             else
%                 density_t(nn)=100-density_b(nn);
%             end
        elseif(density_b(nn)>0)&&(density_c(nn)>0)&&(density_t(nn)<=0)
            density_t(nn)=0;
            density_c(nn)=100-density_b(nn);
%             if (100-density_b(nn))<0
%                 density_b(nn)=100-density_c(nn);
%             else
%                 density_c(nn)=100-density_b(nn);
%             end
        elseif(density_b(nn)<=0)&&(density_c(nn)<=0)&&(density_t(nn)>0)
            density_t(nn)=100;
            density_b(nn)=0;
            density_c(nn)=0;
        elseif(density_b(nn)<=0)&&(density_c(nn)>0)&&(density_t(nn)<=0)
            density_t(nn)=0;
            density_b(nn)=0;
            density_c(nn)=100;
        elseif(density_b(nn)<=0)&&(density_c(nn)>0)&&(density_t(nn)>0)
            density_b(nn)=0;
            density_t(nn)=100-density_c(nn);
%             if (100-density_c(nn))<0
%                 density_c(nn)=100-density_t(nn);
%             else
%                 density_t(nn)=100-density_c(nn);
%             end
        elseif(density_b(nn)<=0)&&(density_c(nn)<=0)&&(density_t(nn)<=0)
            density_b(nn)=0;
            density_c(nn)=0;
            density_t(nn)=100;
        end
        
        %detect new bone formation and identify new elements contactinng the bone
        if density_b(nn)>50
            for mm=1:no_of_elements
                if  ContactMatrix(nn+1,mm+1)~=0
                    ContactMatrix(nn+1,mm+1)=3;
                    ContactMatrix(mm+1,nn+1)=3;
                end
            end
        end
    end
    
    %calculate the mean density of all tissue types in the callus
    density_b_mean = mean(density_b);
    density_b_array(ii) = density_b_mean;
    density_c_mean = mean (density_c);
    density_c_array(ii) = density_c_mean;
    density_t_mean = mean (density_t);
    density_t_array(ii) = density_t_mean;
    
    %calculate E,v,p
    %different rules of mixture can be used here, command out the ones you
    %dont want to use, only left one
    % Rule 3: E=E_t+(E_c-E_t).*(0.01*density_c).^3+3*(0.01*density_c).^2.*(density_b*0.01)...
        %*(E_c-E_t)+3*(0.01*density_b).^2.*(density_c*0.01).*(E_c-E_t)+(E_b-E_t).*(0.01*density_b).^3; 
    
    % Rule 1: E=E_t+(E_b-E_t)*(0.01*density_b).^4.5 + (E_c-E_t)*(0.01*density_c).^3;
    % Rule 2: 
    E=E_t*(density_t*0.01).^3+E_b*(0.01*density_b).^3+E_c*(0.01*density_c).^3;
    E_mean = mean (E);
    v=v_b*(0.01*density_b) + v_c*(0.01*density_c) + v_t*(0.01*density_t);
    v_mean = mean (v);
    p=p_b*(0.01*density_b) + p_c*(0.01*density_c) + p_t*(0.01*density_t);
    p_mean=mean (p);
    
    %write density of all tissue types in individual text file
    fileID = fopen('density_b.txt','w');
    fprintf(fileID,'%12.8f\n',density_b);
    fclose(fileID);
    fileID = fopen('density_c.txt','w');
    fprintf(fileID,'%12.8f\n',density_c);
    fclose(fileID);
    fileID = fopen('density_t.txt','w');
    fprintf(fileID,'%12.8f\n',density_t);
    fclose(fileID);
    
    %write density of all tissue types and strains in one text file for
    %Fortran
    element=[elements(1):elements(2)];
    density=[element; density_b; density_c];
    strain=[strain_v;strain_d];
    fileID = fopen('density.txt','w');
    print=[density; strain];
    fprintf(fileID,'%12s %12s %12s %12s %12s\n','element','bone','cartilage','dilational','distortional');
    fprintf(fileID,'%12.8f %12.8f %12.8f %12.8f %12.8f\n',print);
    fclose(fileID);
    
    %write new E, v, p into dat file
    kk=1;
    fid=fopen(fname,'w');
    for kk=1:length(REF_TABLE)
        REF_TABLE(3,kk)=E(kk);
        REF_TABLE(4,kk)=v(kk);
        REF_TABLE(5,kk)=p(kk);
        
        E_dat=fromNumtoMarc(E(kk));
        v_dat=fromNumtoMarc(v(kk));
        p_dat=fromNumtoMarc(p(kk));
        
        E_dat=E_dat{:};%change from cell to double 
        v_dat=v_dat{:};
        p_dat=p_dat{:};
        
        changeline=Datfile{REF_TABLE(2,kk)};
        changeline(1:20)=E_dat;
        changeline(21:40)=v_dat;
        changeline(41:60)=p_dat;
        
        Datfile{REF_TABLE(2,kk)}=changeline;
    end
    
    fprintf(fid, Datfile{1});
    for k=2:length(Datfile)-1
        fprintf(fid,'%s\n', Datfile{k,1});
    end
    fclose('all');
    
    ii=ii+1;
end

%plot graphs
figure;
plot(0:ii-2, E_array(1:ii-1),'r--o','LineWidth',2);
title ('Youngs modulus change with iteration');
xlabel('iteration');
ylabel('Youngs modulus (MPa)');

figure;
plot(0:ii-2, v_array(1:ii-1),'b--o','LineWidth',2);
title ('Poissons ratio change with iteration');
xlabel('iteration');
ylabel('Poissons ratio');

figure;
plot(0:ii-2, p_array(1:ii-1),'r--o','LineWidth',2);
title ('mass density change with iteration');
xlabel('iteration');
ylabel('Mass density (kg/(mm^3))');

figure;
plot(0:ii-2, density_b_array(1:ii-1),'r--o','LineWidth',2);
hold on;
plot(0:ii-2, density_c_array(1:ii-1),'b--o','LineWidth',2);
hold on;
plot(0:ii-2, density_t_array(1:ii-1),'g--o','LineWidth',2);
title ('tissue percentage change with iteration');
xlabel('iteration');
ylabel('percentage (%)');
legend('bone','cartilege','soft tissue');

figure;
plot(0:ii-2, disp_array(1:ii-1),'g--o','LineWidth',2);
title ('IFM change with iteration');
xlabel('iteration');
ylabel('displacement (mm)');

figure;
plot(0:ii-2, load_array(1:ii-1),'g--o','LineWidth',2);
title ('bone load change with iteration');
xlabel('iteration');
ylabel('load (N)');

%write all data in a excel file
filename = 'test.xlsx';
print1=[0:ii-2; E_array(1:ii-1); v_array(1:ii-1);p_array(1:ii-1);...
density_b_array(1:ii-1); density_c_array(1:ii-1); density_t_array(1:ii-1);...
disp_array(1:ii-1); load_array(1:ii-1)]';
xlswrite(filename,print1,1);






