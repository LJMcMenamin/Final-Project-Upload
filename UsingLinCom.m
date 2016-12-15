% This script runs the function 'LinCom' for every row of a set of emitdt
% vectors, to produce 'emitdtest', a version of emitdt recreated using the
% reduced basis. It finds the maximum differences between the original and
% recreated time delay vectors and plots these on a histogram. It then uses
% a spline interpolation on emitdtest to fill out the time delay vector
% with intermediate time delay data between existing data.




%% Set up
%emitdt size
size = 50;

%waveform length
wl = 1000;

%vector to fill with the times taken for each iteration of the loop
interpend = zeros(size,1);

%vector to fill with the created version of emitdt, 'emitdtest'
emitdtest = zeros(size,wl);

%use correct length of RB_matrix
Usable_RB_matrix = RB_matrix(:,(round(linspace(4,length(RB_matrix)-4, wl)))); 

%% Create version of emitdt form the coefficients 'emitdtest'

for i = 1:size
    
    %start timing how long each interpolation iteration takes
    interpstart = tic;
   
    %use 'LinCom' to re-create emitdt as emitdtest as a linear combination 
    %of the vectors in the reduced basis
    emitdtest(i,:) = LinCom(emitdt(i,:), Usable_RB_matrix);
    
    %end of timing
    interpend(i) = toc(interpstart);
end

%% Create more data points in between the existing emitdt vector

%Create the tgps points over which to find emitdt values
samplerange = min(tgps):1:max(tgps);

%loop will only work provided there is no previous interpolated data in the
%workspace
clear big_emitdtest

for s = 1:size
    %Use a spline interpolant to fill out the time delay vectors 
    big_emitdtest(s,:) = spline(tgps,emitdtest(s,:),samplerange);
end


%% Make graphs

%find the maximum difference between the original emitdt and the newly
%created emitdt
MaxDif = max(emitdt'-emitdtest');

%create a histogram of the maximum differences between the old and new
%emitdt
figure
hist(MaxDif)
title('differences between original and recreated time delay vectors')
xlabel('difference')
ylabel('occurrences')

%create a histogram of the times taken to create each emitdtest vector
figure
hist(interpend)
title('interpolation method times')
xlabel('time taken to recreate emitdt vector')
ylabel('occurrences')

%plot example of original emitdt with interpolated emitdt
plot(tgps,emitdt(1,:),'x',samplerange,big_emitdtest(1,:),'g')
title('original and interpolated time delay vectors over 1 day')
xlabel('tgps')
ylabel('original and interpolated time delays'