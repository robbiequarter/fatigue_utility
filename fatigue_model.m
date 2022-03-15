clear all
close all

% Utility Model Practice
% Define Functions

% utility
    J = @(myalpha,myb,myd,mym,mygamma,myT)...
        ((myalpha-(mym.*myb.*myd./myT))./(1+mygamma.*myT));

% Just effort
    eff = @(myb,myd,mym,mygamma,myT)...
        (-(mym.*myb.*myd./myT)./(1+mygamma.*myT));

% Just reward
    rwd = @(myalpha,mygamma,myT)...
        ((myalpha)./(1+mygamma.*myT));

% optimal duration
    Tstar = @(myalpha,myb,myd,mym,mygamma)...
        ((myb*myd*mygamma*mym+sqrt(myalpha*myb*myd*mygamma*mym+myb^2*myd^2*mygamma^2*mym^2))...
        /(myalpha*mygamma));

%% Computations
% initial parameters healthy
    myalpha = 1500;
    myb = 10;
    mygamma = 1;
    myd = 1;
    mym = 2;

% initial parameters MS
    msalpha = 0.9*myalpha;
    msb = myb;
    msgamma = 0.34*mygamma;
    msd = myd;
    msm = 3*mym;
    
    % scaling factors, for use in plotting
    alphascale = msalpha/myalpha;
    mscale = msm/mym;
    gamscale = msgamma/mygamma;

% Time
    T = 0:0.01:2; 

% Calculate J
    myJ = J(myalpha,myb,myd,mym,mygamma,T);
    myJ1 = J(myalpha,myb,myd,msm,mygamma,T); % double m (effort)
    myJ2 = J(myalpha,myb,myd,mym,msgamma,T); % halve gamma (impulsivity)
    myJMS = J(msalpha,msb,msd,msm,msgamma,T);% MS - effort (m) and gamma
    % myJMS = J(0.5*myalpha,myb,myd,2*mym,mygamma,myT);% MS - effort (m) and gamma

% Calculate T* 
    myTstar = Tstar(myalpha,myb,myd,mym,mygamma);
    myTstar1 = Tstar(myalpha,myb,myd,msm,mygamma); % double m (effort)
    myTstar2 = Tstar(myalpha,myb,myd,mym,msgamma); % halve gamma (impulsivity)
    myTstarMS = Tstar(msalpha,msb,msd,msm,msgamma); % MS - effort (m) and gamma
    % myTstarMS = Tstar(0.5*myalpha,myb,myd,2*mym,mygamma); % MS - effort (m) and gamma

% Find maximal utility, J*, at optimal duration, T*
    Jstar = J(myalpha,myb,myd,mym,mygamma,myTstar);
    Jstar1 = J(myalpha,myb,myd,msm,mygamma,myTstar1); % double m (effort)
    Jstar2 = J(myalpha,myb,myd,mym,msgamma,myTstar2); % halve gamma (impulsivity)
    JstarMS = J(msalpha,msb,msd,msm,msgamma,myTstarMS); % MS - effort (m) and gamma
    % JstarMS = J(0.5*myalpha,myb,myd,mym,mygamma,myTstarMS); % MS - effort (m) and gamma

figure
    hold on
        plot(T,myJ, 'g', 'LineWidth', 1.5) % utility
        plot(T, myJMS, 'g--', 'LineWidth', 1.5) % ms utility
        plot(T, eff(myb,myd,mym,mygamma,T), 'b', 'LineWidth', 1.5)  % effort
        plot(T, eff(msb,msd,msm,msgamma,T), 'b--', 'LineWidth', 1.5)  % ms effort
        plot(T, rwd(myalpha, mygamma, T), 'r', 'LineWidth', 1.5) % reward
        plot(T, rwd(msalpha, msgamma, T), 'r--', 'LineWidth', 1.5) % ms reward
        line([0 max(T)],[0 0],'color', 'k')
        line([myTstar myTstar],[0 Jstar],'color','g', 'LineWidth', 1.5)
        line([myTstarMS myTstarMS],[0 JstarMS],'color','g', 'LineStyle', '--', 'LineWidth', 1.5)
        ylim([-1500 1700]);
        title(sprintf('MS Utility\n (all changes)'))
    hold off
beautifyfig;

%% 
figure
subplot(1,3,1)
    hold on
        plot(T,myJ, 'g', 'LineWidth', 1.5) % utility
        plot(T, myJ1, 'g--', 'LineWidth', 1.5) % ms utility
        plot(T, eff(myb,myd,mym,mygamma,T), 'b', 'LineWidth', 1.5) % effort
        plot(T, eff(msb,msd,msm,mygamma,T), 'b--', 'LineWidth', 1.5) % ms effort
%         plot(T, rwd(myalpha, mygamma, T), 'r', 'LineWidth', 1.5) % reward
        line([0 max(T)],[0 0],'color', 'k')
        line([myTstar myTstar],[0 Jstar],'color','g', 'LineWidth', 1.5)
        line([myTstar1 myTstar1],[0 Jstar1],'color','g', 'LineStyle', '--','LineWidth', 1.5)
        ylim([-1500 1200]);
        ylabel("Utility (J/s)")
        title(sprintf('MS Effort\n b = %.2f', mscale))
    hold off
    
    subplot(1,3,2)
    hold on
        plot(T,myJ, 'g', 'LineWidth', 1.5) % utility
        plot(T, myJ2, 'g--', 'LineWidth', 1.5) % ms utility
%         plot(T, eff(myb,myd,mym,mygamma,T), 'b', 'LineWidth', 1.5) % effort
        plot(T, rwd(myalpha, mygamma, T), 'r', 'LineWidth', 1.5) % reward
        plot(T, rwd(msalpha, msgamma, T), 'r--', 'LineWidth', 1.5) % ms reward
        line([0 max(T)],[0 0],'color', 'k')
        line([myTstar myTstar],[0 Jstar],'color','g', 'LineWidth', 1.5)
        line([myTstar2 myTstar2],[0 Jstar2],'color','g', 'LineStyle', '--', 'LineWidth', 1.5)
        ylim([-1500 1200]);
        xlabel("Time (s)");
        title(sprintf('MS Reward\n alpha = %.2f, gamma = %.2f', alphascale, gamscale))
    hold off
    
    subplot(1,3,3)
    hold on
        plot(T,myJ, 'g', 'LineWidth', 1.5) % utility
        plot(T, myJMS, 'g--', 'LineWidth', 1.5) % ms utility
        plot(T, eff(myb,myd,mym,mygamma,T), 'b', 'LineWidth', 1.5)  % effort
        plot(T, eff(msb,msd,msm,msgamma,T), 'b--', 'LineWidth', 1.5)  % ms effort
        plot(T, rwd(myalpha, mygamma, T), 'r', 'LineWidth', 1.5) % reward
        plot(T, rwd(msalpha, msgamma, T), 'r--', 'LineWidth', 1.5) % ms reward
        line([0 max(T)],[0 0],'color', 'k')
        line([myTstar myTstar],[0 Jstar],'color','g', 'LineWidth', 1.5)
        line([myTstarMS myTstarMS],[0 JstarMS],'color','g', 'LineStyle', '--', 'LineWidth', 1.5)
        ylim([-1500 1200]);
        title(sprintf('MS Utility\n (all changes)'))
    hold off
    
    beautifyfig;
