%% MT/RT Utility Model 
% Requires mymtrtfun.m
close all 
clear all

runsim = 1;

%% Set Old/Young Metabolic Parameters

global param
    
param.myc0 = -5; % accuracy parameters; shifts logistic to the right with scaling
param.myc1 = 10; % accuracy parameters; shifts logistic to the left with scaling
param.mya = 77; % effort offset 
param.myb = 12; %b in metabolic equation (new = 11)
param.myi=1.23;  %exponent on distance
param.beta = 0.3;
param.gamma = 0.75;

param.myeffscale = 1; 

%distance
d=0.1;

%range of alpha values
myalphas=40:80;
% myalphas=20:100; % iterating over different levels of reward to see what happens

%range of SCALING on effort, alpha, and probability terms - used in
%optimization
% myeffscales = 0.8:0.1:1.2;
% myalphascales= 0.8:0.1:1.2;
myeffscales=1.0;
myalphascales=1.0;
myprobscales=1.0;

%% Run Optimization

% use this index to focus on alpha of a certain value
alphaind=find(myalphas==40);
alphascaleind=find(myalphascales==1);
effscaleind=find(myeffscales==1);
probscaleind= find(myprobscales==1);
myrange=find(myalphascales>=0.7);

tic
if runsim
    for i=1:length(myalphas) %loop over all alpha values
        param.myalpha=myalphas(i);
        %disp(i)
        for j=1:length(myeffscales) %loop over effort scaling
            param.myeffscale=myeffscales(j);
            for k=1:length(myalphascales) %loop over alpha scaling
              param.myalphascale=myalphascales(k);  
              for m=1:length(myprobscales) %loop over probability scaling
                  param.myprobscale=myprobscales(m);
%                   param.myprobscale=1.0; 
                  % for use in moving effort/alpha scale simultaneously. 
                  % Comment out above line, below line, 
                  % and if/else for optimization loop.
                    
                  mycond = (j==effscaleind) + (k==alphascaleind) + (m==probscaleind);
                  
                  if (mycond == 2 || mycond == 3) %only run optimization if all scalings are 1 OR only one scaling is not one (dont allow more variations)
                      options = optimset('Display','off','MaxFunEvals',100000,'MaxIter',100000);
                      [sol,fval,exitflag,output] = fmincon(@fatigue_fun,[0 0],[],[],[],[],[0],[],[],options); %using fmincon, second [0,0] is a lower bound on guesses
                      mysols(i,j,k,m,:)=sol;
                  end
              end
            end
        end
    end
end
toc

%% Duration vs. Alpha Figures for range of Effort Valuation/ Reward Valuation/ Probability Scaling
alphaind=find(myalphas==60);
mydurs = squeeze(mysols(:,1,1,1,1));
myJs = fatigue_fun_vec(mydurs);


Er=@(T,a,b) -(a.*T + b./(T)); %reaching cost, basically normal effort cost (no distance, mass, etc.)
Pr=@(T,c0,c1) (1./(1 + exp(-c0 - c1.*T))); %Probability of reward as a function of reach time (T)
F = @(Er,alpha,beta,gamma) (beta.*Er + gamma.*alpha);

figure
    plot(myalphas, -myJs)

figure
    param.myalpha = myalphas(alphaind);
    time = linspace(0,1.5,100);
    uts = fatigue_fun_vec(time);
    plot(time, -uts,'g')
    hold on
    plot(time, Er(time,param.mya,param.myb),'r--')
    plot(time, param.myalpha./(1+param.gamma.*time),'b--')
    myf = F(Er(time, param.myeffscale * param.mya, param.myeffscale * param.myb),param.myalpha,param.beta,param.gamma);
    plot(time,myf,'k')
    xline(mydurs(alphaind))
    ylim([-150 150])
    hold off


figure
for i = 1:5:length(myalphas)
    myfs = F(Er(mydurs, param.myeffscale * param.mya, param.myeffscale * param.myb),myalphas(i),param.beta,param.gamma);
    plot(mydurs,myfs,'DisplayName',sprintf('alpha = %d',myalphas(i)))
    hold on
end
legend(gca, "show")