clc; clear

S0_values = [10, 25, 60, 75, 100];
% Time span
tspan = [0 150]; %hours
t_eval = linspace(0, 150, 200); % Common time points for output

[t, Y] = ode15s(@(t, Y) batch(t, Y), tspan, [0.1; 60; 0]);

productivity = (Y(end, 3) - Y(1, 3))/ (t(end, 1) - t(1, 1))

X_out = zeros(length(t_eval), length(S0_values));
S_out = zeros(length(t_eval), length(S0_values));
P_out = zeros(length(t_eval), length(S0_values));
legendd = {};

 for i = 1:length(S0_values)
        % Initial conditions [X0, S0, P0]
        Y0 = [0.1; S0_values(i); 0];
        
        % Solve the ODE system
        [t, Y] = ode15s(@(t, Y) batch(t, Y), tspan, Y0);
        
        % Store results for plotting
        % Interpolate results to common time points
        X_out(:, i) = interp1(t, Y(:, 1), t_eval);
        S_out(:, i) = interp1(t, Y(:, 2), t_eval);
        P_out(:, i) = interp1(t, Y(:, 3), t_eval); % Product
        legends{i} = sprintf('S0 = %g g/L', S0_values(i));
 end

% Plot results
figure;
subplot(3,1,1);
plot(t_eval, X_out, 'LineWidth', 2);
title('C. Glutamicum Concentration');
ylabel('X (g DCW/L)');
% legend(legends);
grid on;

subplot(3,1,2);
plot(t_eval, S_out, 'LineWidth', 2);
title('Glucose Concentration');
ylabel('S (g/L)');
legend(legends);
grid on;

subplot(3,1,3);
plot(t_eval, P_out, 'LineWidth', 2);
title('MA Concentration');
xlabel('Time (hr)');
ylabel('P (g MA/L)');
% legend(legends);
grid on;
sgtitle('Concentration profiles for Batch process')

