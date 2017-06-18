function [str_Val]=fromNumtoMarc(Number)
In_char=num2str(Number,'%1.17E');
position_E=strfind(In_char,'E');
F_part=In_char(1:(position_E-1));
L_part=In_char((position_E+2):length(In_char));
SI=In_char(position_E+1);
L_P=str2double(L_part);
L_part=num2str(L_P);
to_remove=length(L_part)+1;
F_part=F_part(1:((position_E-1)-to_remove));
str_Val = strcat(F_part,SI,L_part);
% if (F_part)~='-'
   str_Val=strcat({' '},str_Val);
% end
end