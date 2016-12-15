%% Using just one set of reduced basis over a tgps of one year has not
    %yet returned results of the desired accuracy. This script aims to
    %improve these results by using 365 sets of emitdt over 365 
    %sequential time vectors.

%% Set up

%Create a matrix filled with 365 sequential days of time data
year = zeros(365, 10);

for k = 1:365
    
    year(k,:) = linspace(900000000+((k-1)*864000), 900000000+(k*864000), 10);

end

stopping tolerance
tol = 1e-12;

waveform length
wl = 10;

emitdt size 
size = 1;

%skeleton emitdt to fill in the loop
emitdtyear = zeros(size, wl);

%vector to fill with the right ascension and
skyposvals = zeros(size,2);

%vector to fill with the iteration times
fullend = zeros(size,1);

%set up progress bar
h = waitbar(0,'Progress');




%% Find emitdt for random values of RA and dec

for j = 1:365
    
for i = 1:size
    
    %starting time for the iteration
    fullstart = tic;
    
    %create random RA
    source.alpha = 2*pi*rand(1);

    %create random Dec
    source.delta = -(pi/2) + acos(2*rand(1) - 1);
    
    %use get_barycenter to find emitdt
    [emitdtyear(j,:), ~, ~, ~, ~, ~, ~] = get_barycenter(year(j,:), 'H1', source, 'earth00-19-DE405.dat', 'sun00-19-DE405.dat');
    
    %this loop only works if the sun and earth ephemeris files are closed
    %during each iteration of the loop
    fclose all;
    
    %stores how long it took the code to create each emitdt vector
    fullend(i) = toc(fullstart);
    
    %store the created emitdt vectors for this day in a stucture called
    %'delays'
    %delays(j).day = emitdtyear;
end

    %as 1000+ iterations of the loop can take 30+minutes, it is helpful to
    %use a progress bar to show how far along the code is
    waitbar(j/365)
    
end

%close the waitbar
close(h)


%% Find the reduced basis

%start timing how long it takes to find the reduced basis
greedystart = tic;

%use the Greedy function to find the small number of vectors which best
%represent the entire basis
for n = 1:365
RB_matrix_year = Greedy(emitdtyear, tol);
end

%store how long it took to find the reduced basis
greedyend = toc(greedystart);

useRByear = RB_matrix_year(:,(round(linspace(4,length(RB_matrix_year)-4, wl))));

for g = 1:365
    emitdtyearest(g,:) = LinCom(emitdtyear(g,:), RB_matrix_year);
end

%find the maximum difference between the original emitdt and the newly
%created emitdt
MaxDifYear = max(emitdtyear'-emitdtyearest');

%create a histogram of the maximum differences between the old and new
%emitdt
figure
hist(MaxDifYear)
title('differences between original and recreated 365 time delay vectors')
xlabel('difference')
ylabel('occurrences')