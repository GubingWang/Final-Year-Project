function [REF_TABLE,elements,Datfile,fname,ContactMatrix]=MultiplyDatFile(~)
%Code for backing out a specific output from a .t16 Marc result file
nbfiles = 0;
%Select dat file
while nbfiles < 1 %make sure that a dat file is selected
    [fname, pathName, ~] = uigetfile('*.dat','MultiSelect','off','Choose Marc model (.dat) files');
    nbfiles = ischar(fname);
end
%The address is pathName\fname to make sure this works
fname=[pathName fname];
datfname=fname;
%Now, let's read the dat file
fid=fopen(fname);
tline=fgetl(fid);
k=1;
Datfile(k,1)={tline};
kk=0;
j=-1;
%While the dat file is read, let's look for material models
while ischar(tline)
    tline=fgetl(fid);
    k=k+1;
    Datfile(k,1)={tline};
    %Here we check for contact bodies
    check=strfind(tline,'isotropic');
    if check>=1
        tline=fgetl(fid);
        k=k+1;
        Datfile(k,1)={tline};
        tline=fgetl(fid);
        k=k+1;
        Datfile(k,1)={tline};
        kk=kk+1;
        j=j+1;
        MAT(kk,1)={tline(91:length(tline))}; %that's the name of the contact body
        MAT(kk,2)={num2str(j)}; %that's the ID of the material - probably you don't need it but hey...
        tline=fgetl(fid);
        k=k+1;
        Datfile(k,1)={tline};
        MAT(kk,3)={num2str(k)}; %line of the dat file you can find the material details
        tline=fgetl(fid);
        k=k+1;
        Datfile(k,1)={tline};
        tline=fgetl(fid);
        k=k+1;
        Datfile(k,1)={tline}; %now these are the element numbers, pretty important to get them right
        number1={tline(1:12)};
        number2={tline(25:length(tline))};
        number1=str2double(number1);
        number2=str2double(number2);
        MAT(kk,4)={number1}; %starting element
        MAT(kk,5)={number2}; %ending element
    end
    check2=strfind(tline,'springs');
    if check2>=1
        tline=fgetl(fid);
        k=k+1;
        Datfile(k,1)={tline};
        Spring_Node={tline(1:10)};
    end
    %Here we check for contact bodies
    check3=strfind(tline,'connectivity');
    if check3>=1
        tline=fgetl(fid);
        k=k+1;
        Datfile(k,1)={tline};
        tline=fgetl(fid);
        k=k+1;
        Datfile(k,1)={tline};
        check4=strfind(tline,'coordinates');
        cc=0;
        while isempty(check4)>=1;
            numberel={tline(1:10)};
            numberel=str2double(numberel);
            node1={tline(21:30)};
            node1=str2double(node1);
            node2={tline(31:40)};
            node2=str2double(node2);
            node3={tline(41:50)};
            node3=str2double(node3);
            node4={tline(51:60)};
            node4=str2double(node4);
            nodeMatrix(numberel,:)=[numberel, node1, node2, node3, node4];
            tline=fgetl(fid);
            k=k+1;
            Datfile(k,1)={tline};
            check4=strfind(tline,'coordinates');
        end
        
        
        
    end
end
%Pick the material model of interest that you will run the optimisation for

while iscell(Spring_Node)==1
    Spring_Node=Spring_Node{:};
end

Spring_Node=str2double(Spring_Node)-1;

str=MAT(:,1);
v=0;

while v < 1
    [matID,v] = listdlg('PromptString','Select a material:',...
        'SelectionMode','single',...
        'ListString',str);
end

%Now, we have a contact body, what about the elements included???
%For this code to work, it means that your contact body has elements in a
%row (ie. 161 to 189)
%first find the ID of callus, then change it to a double type
line=MAT(matID,3);
line=line{:};
line=str2double(line); 

changeline=Datfile{line};
E_initial=' 3.000000000000000+0';
v_initial=' 3.000000000000000-1';
p_initial=' 3.800000000000000-7';
changeline(1:20)=E_initial;
changeline(21:40)=v_initial;
changeline(41:60)=p_initial;
Datfile{line}=changeline;

elements=[MAT{matID,4};MAT{matID,5}];
size_of_blanks=elements(2)-elements(1);
fclose('all');
%%%%%%%%% - IF THIS HAS BEEN DONE BEFORE THEN JUST READ FROM TXT - IT TAKES TIME
choice = questdlg('Do you want to read the contact matrix from an existing text file?', ...
    'WARNING: In case it is the 1st time it takes longer to run'); %click yes to save time 

if strcmp(choice,'No')==1
    nodeMatrix=nodeMatrix(elements(1):elements(2),:);
    
    [m,n]=size(nodeMatrix);
    ContactMatrix=zeros(m+1,m+1);
    ContactMatrix(2:m+1,1)=nodeMatrix(:,1);
    ContactMatrix(1,2:m+1)=(nodeMatrix(:,1));
    
    for i=1:m;
        A=nodeMatrix(i,2:n);%the nodes of an element 
        for j=i+1:m;
            B=nodeMatrix(j,2:n);
            no=length(intersect(A,B))%check how many nodes the two elements share 
            ContactMatrix(i+1,j+1)=no;
            ContactMatrix(j+1,i+1)=no;
        end
    end
    
%%%%%%%tackle this
    NodList=nodeMatrix(:,1).';
    NodList(m+1:2*m)=nodeMatrix(:,2).';
    NodList(2*m+1:3*m)=nodeMatrix(:,3).';
    NodList(3*m+1:4*m)=nodeMatrix(:,4).';
    NodList=sort(NodList);
    
    nodesofinterest = NodList(histc(NodList,NodList) == 2);%only record the node numbers that appeared twice
    nodesofinterest = [nodesofinterest, NodList(histc(NodList,NodList) == 1)];%only record the node that appeared once    nodesofinterest = sort(nodesofinterest);
    nodesofinterest = nodesofinterest-1;
    
    fid=fopen('Contact_nodes\nodelist.txt','w');
    for i=1:length(nodesofinterest)
        fprintf(fid,'%d\n', nodesofinterest(i));
    end
    fclose('all');
    fileP=[pathName 'Contact_nodes\RunContact.bat'];
    system(fileP);
    fileP=[pathName 'Contact_nodes\outputCONTACT.txt'];
    Contact=dlmread(fileP);
    fclose('all');
    B_Check=Contact(:,2)>=1;
    Contact=Contact(B_Check);
    MAP=nodeMatrix(:,2:n);
    for ci=1:length(Contact)
        Nno=Contact(ci);
        [ROW,~] = find(MAP == Nno);
        if isempty(ROW)>0;
            ContactMatrix(ROW+1,ROW+1)=3;
        end
    end
    
   fileP=[pathName 'Contact_nodes\Contact_Matrix.txt'];
   dlmwrite(fileP,ContactMatrix,'\t');
   fclose('all');
elseif strcmp(choice,'Yes')==1;
   fileP=[pathName 'Contact_nodes\Contact_Matrix.txt'];
   ContactMatrix=dlmread(fileP,'\t');
   fclose('all');
else
    quit;
end
%IT TAKES A WHILE TO RUN, SO IF IT'S DONE BEFORE READ THE TXT DIRECTLY
%now we separate the callus into elements with their individual material
%properties 
mm=length(Datfile);
Datfile(line+3+(size_of_blanks*6):mm+(size_of_blanks*6))=Datfile(line+3:mm);
Datfile(line+2)=NumtoMarc_FOREL(elements(1),12);
k=line+3;
for i=2:size_of_blanks+1
    Datfile(k)={'isotropic'};
    k=k+1;
    Datfile(k)={''};
    k=k+1;
    newpart=NumtoMarc_FOREL(elements(1)+i-1,10);
    oldpart={'elastic                                         10         0         0         0mat'};
    Datfile(k)=strcat(newpart,oldpart,{num2str(elements(1)+i-1)});
    k=k+1;
    Datfile(k)=Datfile(line);
    k=k+1;
    Datfile(k)=Datfile(line+1);
    k=k+1;
    Datfile(k)=NumtoMarc_FOREL(elements(1)+i-1,12);
    k=k+1;
end

REF_TABLE(1,1)=elements(1);
REF_TABLE(2,1)=line;

for i=2:size_of_blanks+1
    REF_TABLE(1,i)=elements(1)+i-1;
    REF_TABLE(2,i)=line+6*(i-1);
end
fclose('all');
fid=fopen(fname,'w');
fprintf(fid,'%s\n', Datfile{1});
for i=2:length(Datfile)-1
    tline=Datfile{i};
    while iscell(tline)==1
        tline=tline{:};
    end
    fprintf(fid,'%s\n', tline);
end
fclose('all');
%python
fname='Back_out_NEW.py';
fname=[pathName fname];

fid=fopen('Back_out_NEW.py');
tline=fgetl(fid);
k=1;
PYfile(k,1)={tline};

%While the python file is read
while ischar(tline)
    tline=fgetl(fid);
    k=k+1;
    PYfile(k,1)={tline};
end

fclose('all');

changeline=PYfile{17};
changeline=changeline(1:28);
changeline=strcat(changeline,num2str(Spring_Node),',0)');
PYfile{17}=changeline;

changeline=PYfile{21};
changeline=changeline(1:16);
changeline=strcat(changeline,num2str(elements(1)-1),{', '},num2str(elements(2)),'):');
PYfile{21}=changeline;

fid=fopen(fname,'w');
fprintf(fid,'%s\n', PYfile{1});
for i=2:length(PYfile)-1
    tline=PYfile{i};
    while iscell(tline)==1
        tline=tline{:};
    end
    fprintf(fid,'%s\n', tline);
end

fclose('all');
% %move the identifier back to dat file
% %Code for backing out a specific output from a .t16 Marc result file
% nbfiles = 0;
% %Select dat file
% while nbfiles < 1 %make sure that a dat file is selected
%     [fname, pathName, ~] = uigetfile('*.dat','MultiSelect','off','Choose Marc model (.dat) files');
%     nbfiles = ischar(fname);
% end
% %The address is pathName\fname to make sure this works
fname=datfname;

end

