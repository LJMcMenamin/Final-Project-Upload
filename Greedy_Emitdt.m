%This script produces n emitdt vectors for n random values of right ascension
%and declination, and then performs the greedy algorithm on this time delay
%to return a reduced basis. It stores the times taken to create each emitdt
%vector, and plots these times on a histogram.




%% Set up
%stopping tolerance
tol = 1e-12;

%no. of vectors in data set 
size = 365;

%waveform length
wl = 10;

%skeleton emitdt to fill in the loop
emitdt = zeros(size, wl);

%vector to fill with the right ascension and
skyposvals = zeros(size,2);

%vector to fill with the iteration times
fullend = zeros(size,1);

%time range over which to find emitdt
%one day = 864000
%one month = 25920000
%one year = 315360000
tgps = linspace(900000000, 900000000+315360000, wl);

%set up progress bar
h = waitbar(0,'Progress');




%% Find emitdt for random values of RA and dec
 
for i = 1:size
    
    %starting time for the iteration
    fullstart = tic;
    
    %create random RA
    source.alpha = 2*pi*rand(1);

    %create random Dec
    source.delta = -(pi/2) + acos(2*rand(1) - 1);
    
    %use get_barycenter to find emitdt
    [emitdt(i,:), ~, ~, ~, ~, ~, ~] = get_barycenter(tgps, 'H1', source, 'earth00-19-DE405.dat', 'sun00-19-DE405.dat');

    %normalise emitdt set
%     DotProd = dot(emitdt(i,:), emitdt(i,:));
%     emitdt(i,:) = emitdt(i,:)/(sqrt(abs(DotProd)));
    
    %record source
    skyposvals(i,1) = source.alpha;
    skyposvals(i,2) = source.delta;
    
    %as 1000+ iterations of the loop can take 30+minutes, it is helpful to
    %use a progress bar to show how far along the code is
    waitbar(i/size)
    
    %this loop only works if the sun and earth ephemeris files are closed
    %during each iteration of the loop
    fclose all;
    
    %stores how long it took the code to create each emitdt vector
    fullend(i) = toc(fullstart);
end

%close the waitbar
close(h)

%save the sky positions created in the loop 
save -ascii -double skyposvals.txt skyposvals





%% Find the reduced basis

%start timing how long it takes to find the reduced basis
greedystart = tic;

%use the Greedy function to find the small number of vectors which best
%represent the entire basis
RB_matrix = Greedy(emitdt, tol);

%store how long it took to find the reduced basis
greedyend = toc(greedystart);




%% Create histogram

%make a histogram which shows the frequencies of each of the times taken to
%create each emitdt vector
figure
hist(fullend)
title('old method times')
xlabel('time taken to find emitdt vector')
ylabel('occurrences')