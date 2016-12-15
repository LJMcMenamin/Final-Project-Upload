function [ emitdtest ] = LinCom( emitdt, RB_matrix )
% This function finds the coefficients required to rebuild emitdt from the
% reduced basis. It then uses these coefficients with the reduced basis to
% actually recreate emitdt as a vector called 'emitdtest'.

%% Find coefficients


%Find m so that matrix dimensions agree later on
[m,n] = size(RB_matrix);
 
%Choose m ~evenly spaced entries from emitdt
spots = round(linspace(4,length(emitdt),m)); 
A = emitdt(spots);
    
%get the same points from each of the reduced bases and put them in a matrix
B = (RB_matrix(:, spots));

%solve and find the coefficients which make emitdt from RB_matrix
coefficients = A\B;

%% We then want to build emitdt using the coefficients found

%Build an version of emitdt from RB_matrix and the coefficients
emitdtest = coefficients*RB_matrix;

end

