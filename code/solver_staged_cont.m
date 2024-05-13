clc; clear;

warning('off','Matlab:ode15s:IntegrationTolNotMet');
% so Matlab will not throw out a lot of errors later

%% Staged-continuous reactor

optsgrad = optimoptions('fmincon', 'Algorithm', 'interior-point');

%multistart to save computing resources
ms = MultiStart('UseParallel', true, 'Display', 'none');

N = 2; %number stages 
mu_max = 0.0729;%/hr %from graphs
V = 7; %data for 7L 

%intialize 
F0 = 0.2*ones(N, 1); %say initial guess
sin0 = 80*ones(N, 1);
t0 = 10*ones(N, 1);
x0 = [F0; sin0; t0]';

%bounds
lb = zeros(1,N*5);
ub = [mu_max*7*ones(1, N); 300*ones(1, N); 100*ones(1, N)]';  % ub for time is 1e3 (say)

%objective
obj_fun = @(xx) obj_function(xx, N);

%combine everything
problemgrad = createOptimProblem('fmincon', ...
    'objective', obj_fun, ...
    'x0', x0, ...
    'lb', lb, ...
    'ub', ub, ...
    'options', optsgrad); %gradient based method

%number of starting points
numSP = 20; 

% Run the MultiStart optimization
rng(253); %decided to go with this
tic; %start timer
[xxSC, fval, exitflag, output, sol] = run(ms, problemgrad, numSP)
time = toc

%% Run the simulation again with optimal parameters (F, sin, t)
[tvec,yvec] = stage_simulation(xxSC, N);
plot_subplot(tvec, yvec)

%% Functions
function [tvec,yvec] = stage_simulation(xx, N)
    % xx are the variables to optimize (3xN variables)
    % N = 3; %variables are in a long list
    
    % F, sin, and t are Nx1 vectors
    F = xx(1:N);
    sin = xx(N+1:2*N);
    t = xx(2*N+1: 3*N);
        
    ti = 0;
    tf = 0;
    Y0 = [0.1; 60; 0];  

    % vectors to store all the x and t
    tvec = [];
    yvec = [];
    
    for i = 1:N % for each stage
        tf = tf + t(i); % t(i) is the duration for each stage
        
        tspan = [ti tf];
        F_now = F(i);
        sin_now = sin(i);
        
        [time, Y] = ode15s(@(t,Y) cstr(t, Y, F_now, sin_now), tspan, Y0);

        % concactanate the new sets of t and relevant state variables
        tvec = [tvec; time];
        
        yvec_new = [Y, ones(length(time),1)*F_now, ones(length(time),1)*sin_now];
        yvec = [yvec; yvec_new];
        % yvec stores X, S, P, F, and sin at each time point
        
        ti = ti + t(i);
        Y0 = Y(end,:);% update the initial guess 
        % the initial guess for the next iter is the last set of state variables
        % from the previous iter
    end

end

function obj = obj_function(xx, N)
    % xx = [F, sin, t] (each row = each time; each column = each variable)
    % t is the time each state variable occurs at
    
    [tvec,yvec]  = stage_simulation(xx, N);
    % yvec stores X, S, P, F, and sin at each time point
    
    P = yvec(:,3);
    F = yvec(:,4);
    
    Pout = trapz(tvec,P.*F);
    
    productivity = (Pout/tvec(end)); 
    obj = productivity* (-1); % for maximization

end
