function dYdt = batch(t, Y)
%function encapsulates batch design equationd for muconic acid 
%production from glucose in C. Glutamicum bacteria

%INPUT - t, Y, kinetic parameters
%OUTPUT - set of odes packed inside dY/dt

    x = Y(1); % Biomass concentration
    s = Y(2); % Substrate concentration
    p = Y(3); % Product concentration

    % parameters from Lee_et_al 2018
    mu_max = 0.0729; %/hr %from graphs
    Ks = 0.5; %guess
    p_max = 50; %assumed
    m = 0.01; %assumed
    
    Yxs = 0.185; %gDCW/g glucose, 
    Ypx = 0.892; %gMA/ gDCW
    Yps = 0.165; 
    V = 7; %L

    % odes
    mu = mu_max * (1-p/p_max)*(s / (Ks + s)); %product inhibition
    dxdt = mu*x ;
    dpdt = dxdt*Ypx ;
    dsdt = - (dxdt/Yxs) - m*x - dpdt/Yps;

    % pack derivatives
    dYdt = [dxdt; dsdt; dpdt];
end
