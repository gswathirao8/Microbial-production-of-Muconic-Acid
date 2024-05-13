function plot_subplot(t,y)
    % yvec stores X, S, P, F, and sin at each time point
    X = y(:,1);
    S = y(:,2);
    P = y(:,3);
    F = y(:,4);
    sin = y(:, 5);

    figure ()
    box on;
    x0 = 15;
    y0 = 15;
    width = 600;
    height = 700;
    set(gcf,'position',[x0,y0,width,height])
    set(0,'defaultAxesFontSize',14)
    set(groot,'DefaultLineLineWidth',1.5)

    subplot(3,1,1)
    hold on
    box on
    plot(t, X)
    ylabel('X (g DCW/L)')
    title('C. Glutamicum Concentration');
    hold off

    subplot(3,1,2)
    hold on
    box on
    plot(t,S)
    ylabel('S (g glucose/L)')
    title('Glucose Concentration');
    hold off

    subplot(3,1,3)
    box on
    plot(t,P)
    xlabel('time (h)')
    ylabel('P (g MA/ L)')
    title('MA Concentration');

    sgtitle('Concentration profiles for staged-continuous process')

    figure()
    subplot(1, 2, 1)
    box on
    plot(t, F)
    xlabel('time (h)')
    ylabel('F (L/h)')

    subplot(1, 2, 2)
    box on
    plot(t, sin)
    xlabel('time (h)')
    ylabel('Inlet glucose concentration (L/h)')
end