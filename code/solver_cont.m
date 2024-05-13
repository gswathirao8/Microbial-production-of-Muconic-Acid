clc; clear
%comment  - low D -> suggests the use of fed-batch

% Initial guesses 
F0 = 0.14; 
Sin0 = 50; 
mu_max = 0.0729;

% Bounds for F and Sin
lb = [0.02*2, 30];
ub = [mu_max*7, 200];

% Options for the optimizer
options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');

% Running the optimization
[optimal_vars, fval] = fmincon(@(x) -simulateCSTR(x(1), x(2)), [F0, Sin0], [], [], [], [], lb, ub, [], options);

%% Run the simulation again with optimal parameters (F, Sin)
tspan = [0 100]; 
Y0 = [0.1, 60, 0];

[tf, Yf] = ode15s(@(t, Y) cstr(t, Y, optimal_vars(1), optimal_vars(2)), tspan, Y0);

%plot evrything
% Plot results
figure;
subplot(3,1,1);
plot(tf, Yf(:, 1), 'LineWidth', 2);
title('C. Glutamicum Concentration');
ylabel('X (g DCW/L)');
grid on;

subplot(3,1,2);
plot(tf, Yf(:, 2), 'LineWidth', 2);
title('Glucose Concentration');
ylabel('S (g/L)');
grid on;

subplot(3,1,3);
plot(tf, Yf(:, 3), 'LineWidth', 2);
title('MA Concentration');
xlabel('Time (hr)');
ylabel('P (g MA/L)');
grid on;
sgtitle('Concentration profiles for Continuous process')


%% Functions

function obj = simulateCSTR(F, Sin)
    % This function simulates the CSTR operation for given F and Sin and
    % returns the productivity

    tspan = [0 100]; % Time span for simulation (hr)
    Y0 = [0.1, 60, 0]; % Initial conditions: Biomass, Substrate, Product concentrations

    [t, Y] = ode15s(@(t, Y) cstr(t, Y, F, Sin), tspan, Y0);

    P = Y(:,3);
    Pout = trapz(t,P.*F);
    % productivity = (Y(end, 3) - Y(1, 3))/ (t(end, 1) - t(1, 1));

    productivity = (Pout/t(end)); 
    obj = productivity* (-1); % for maximization
end