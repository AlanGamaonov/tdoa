function [GPS, X] = func_read_file(Name)

ID = fopen(Name, 'r');
GPS = textscan(ID, '%s', 6, 'Delimiter', '\n', 'MultipleDelimsAsOne', 1);
X = fscanf(ID, '%f');
fclose(ID);

end

