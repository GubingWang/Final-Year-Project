function [str_Val]=NumtoMarc_FOREL(El,no)
In_char=num2str(El);
n=no-length(In_char);
str_Val=' ';
for i=1:n
    str_Val=strcat({' '},str_Val);
end
str_Val=strcat(str_Val,In_char);

end

