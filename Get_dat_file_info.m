[fname, pathName, ~] = uigetfile('*.dat',['Select dat file']);
filname={[pathName fname]};
fid=fopen(filname{:});

jj = 1;
    tline = fgets(fid);
    B{jj} = tline;
    while ischar(tline)
        jj = jj+1;
        tline = fgetl(fid);
        B{jj} = tline;
    end
    fclose(fid);
    
    