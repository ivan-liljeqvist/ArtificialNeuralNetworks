
%define variables
hidden=200;
epoch=300;


%the bottom plane is X and Y
x=[-5:0.1:5]';
y=x;
%the terrain is Z.
z=exp(-x.*x*0.1) * exp(-y.*y*0.1)' - 0.5;

%the size of the graph
gridsize = size(x, 1);
ndata = gridsize*gridsize;
eta = 0.001;
alpha = 0.9;

n = gridsize;


%Transform z into a vector with 1 rows and num_points columns
targets = reshape (z, 1, ndata);
%Meshgrid, take x and y and produce matrices xx and yy
[xx, yy] = meshgrid (x, y);
%Create a matrix 
patterns = [reshape(xx, 1, ndata); reshape(yy, 1, ndata)];

%randomize the matrixes
permute = randperm(size(targets,2));
[p1, inv_perm] = sort(permute);
patterns = patterns(:, permute);
targets = targets(:, permute);

sub_patterns = patterns(:, 1:n);
sub_patterns2 = patterns(:, n:gridsize);

sub_targets = targets(:, 1:n);
sub_targets2 = targets(:, n:gridsize);


[insize, ndata] = size(patterns);
[outsize, ndata] = size(targets);


%
%rand returns interval (0,1) we want interval (?1/?d,1/?d), therefore we
%take -2*1/?d and then +1/?d

%we want input to the node to be between -1 and 1, therefore we "normalize"
%the weight value with this formula. We want the input to the node to be

%from -1 to 1 because the S function inside the node only differs between
%-1 and 1, lesser and greater values are just the same. So we want to land
%somewhere between -1 and 1 on the S-func to get variating values.


v = rand(outsize,hidden+1)* 2/sqrt(insize) - 1/sqrt(insize);
w = rand(hidden,(insize+1))* 2/sqrt(insize) - 1/sqrt(insize);

dv = zeros(outsize,(hidden+1));
dw = zeros(hidden,(insize+1));

X = [patterns; ones(1,ndata)];
X1 = [sub_patterns; ones(1, n)];


for i = 1:epoch 
    
    %FIRST PASS
    
    %Forward
    hin = w * X1;
    hout = [2 ./ (1+exp(-hin)) - 1 ; ones(1,n)];
    oin = v * hout;
    out = 2 ./ (1+exp(-oin)) - 1;
    
    %Backprop
    delta_o = (out - sub_targets) .* ((1 + out) .* (1 - out)) * 0.5;
    delta_h = (v' * delta_o) .* ((1 + hout) .* (1 - hout)) * 0.5;
    delta_h = delta_h(1:hidden, :);
    
    %Update weights
    dw = (dw .* alpha) - (delta_h * X1') .* (1-alpha);
    dv = (dv .* alpha) - (delta_o * hout') .* (1-alpha);
    w = w + dw .* eta;
    v = v + dv .* eta;
    
    
    

end


%SECOND PASS
    
hin = w * X;
hout = [2 ./ (1+exp(-hin)) - 1 ; ones(1,ndata)];
oin = v * hout;
out = 2 ./ (1+exp(-oin)) - 1;

ordered_out = out(:,inv_perm);

zz = reshape(ordered_out, gridsize, gridsize);
mesh(x,y,zz);
axis([-5 5 -5 5 -0.7 0.7]);
drawnow;

error = sum(sum(abs(sign(out) - targets)./2))


%we get 40 error when we run with all datapoints because we have too few data points, if we decrease
%stepsize in input we'll get a small error. If we give a subset then the
%function wont know how to fit the curve. (Blue lines in the lecture). so
%we'll get an area (calculated with Beysian) where the real chart could be


%If we take too small stepsize, we run the risk of overfitting. We need to:

%1) adjust Hidden (number of nodes) so that we dont have too many and not too
%few. Too many = not needed weights, will try to go towards zero, but with
%time the values still can accumulate. Too few = too few nodes to describe
%the problem.

%2)adjust Epochs. If too few = not enough epochs to learn. If too many =
%the network can go in unexpected direction?? (not sure)


