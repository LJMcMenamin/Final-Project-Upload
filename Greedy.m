function [ RB_space ] = Greedy( TS, tol)
%Perform greedy algorithm (using IMGS) to form a reduced basis from a given training set.
%Inputs TS (a ndarray containing a set of normalised training vectors), wt
%(a weight, or vector of weights, for normalisation), and tol (a stopping
%criterion for the algorithm).


%stopping criterion
tol = 1e-12;

%rows = number of training waveforms and cols = length of each training waveform
[rows, cols] = size(TS);

%setting stuff up for loop
continuework = true;
last_rb = zeros(1,cols);
ortho_basis = zeros(1,cols);
errors = zeros(1,rows);
A_row_norms2 = zeros(1,rows);
projection_norms2 = zeros(1,rows);
greedy_points = zeros(1,rows);
greedy_err = zeros(1,rows);

%initialse first reduced basis to zeros
RB_space = zeros(1,cols);


for i = 1:rows;
    A_row_norms2(i) = sqrt(abs(dot(TS(i,:), TS(i,:)))) ;
end

%initialise with the first training set
RB_space(1,:) = TS(1,:) ;
greedy_points(1) = 0;
dim_RB = 2;
greedy_err(1) = 1;
     

%projections = zeros(tssize*length(TS)); 

while continuework
    %previous bases
    last_rb = RB_space((dim_RB - 1), :);

    %Compute overlaps of pieces of TS with rb_new
        for i = 1:rows
            projection_coeff = dot(last_rb, TS(i,:));
            projection_norms2(i) = projection_norms2(i) + (real(projection_coeff^2) + imag(projection_coeff^2)) ;
            errors(i) = A_row_norms2(i) - projection_norms2(i);
     
        end
        
    %find worst represented TS element and add to basis - argmax just max?
    [~,i] = max(errors);
    worst_err = errors(i);
    worst_app = i;

    greedy_points(dim_RB) = worst_app;
    greedy_err(dim_RB) = worst_err;

    fprintf(1, '%d: Max. Err. %e, for training waveform %d\n', dim_RB, worst_err, worst_app);

    orthobasis = (TS(worst_app,:));
    orthobasis = IMGS(orthobasis, RB_space);
    
    RB_space = vertcat(RB_space, orthobasis);

    dim_RB = dim_RB + 1;
    
       
 
%decide if another greedy sweep is needed
    if worst_err < tol 
        continuework = false;
    elseif rows == dim_RB
        continuework = false;
    end

end

end

