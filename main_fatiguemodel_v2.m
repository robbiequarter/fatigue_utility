% Recreating the fatigue-weighted subjective value model from Muller et
% al., 2021
%   Supplementary info for paper: https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-021-24927-7/MediaObjects/41467_2021_24927_MOESM1_ESM.pdf

clear all 

% set seed
rng(69) 

%% Initialize parameters
global param

trials = [1:20]'; % simulate 250 trials
% mvc = 5;
% rwds = 2:2:10; % rewards, from paper
% effs = mvc.*[.30 .39 .48 .57 .66]; % %MVC effort, from paper
% effs = 2:2:10;
% Trest = 5; % Rest period. Longer rests result in higher proportion of decisions to work

% Initialize subject-specific parameters (between 0 and 1.1)
param.k = 0.065; % discounting, restrict to not go below 0.0276 (0.065 is approx. mean from supplementary info)
param.alpha = 0.3; % RF work scale (approx. mean = 0.3) - increasing this causes less decisions to work
param.delta = 0.25; % RF rest scale (approx. mean = 0.25) - increasing this causes more decisions to work
param.theta = 0.018; % UF effort scale (approx. mean = 0.018) - increasing this causes less decisions to work

% Initialize decision landscape
% options = combvec(effs, rwds)';
% work = datasample(repmat(options,10,1),length(trials),1,'Replace',false); % effort and reward choices
% rest = [zeros([length(trials),1]), ones([length(trials),1])]; % rest option: 0 effort, 1 reward

% initialize storage arrays
mysols = zeros([length(trials),1]);
myJs = zeros([length(trials),1]);
rfuf = zeros([length(trials)+1, 2]); %RF col 1, UF col 2. Initial values = 0 from paper

% Initialize movement-specific parameters
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
val = 5; % reward value
myalphas = val.*ones([1,length(trials)]); 

%range of SCALING on effort, alpha, and probability terms
myeffscales=1.0;
myalphascales=1.0;
myprobscales=1.0;



%% Main loop for decision-making 

% Loop and make decisions
for i = 1:length(trials)
   % Presented objective reward 
   param.r = myalphas(i);
   
   % Prior fatigue
   param.rfprev = rfuf(i,1);
   param.ufprev = rfuf(i,2);
   
   % Find optimal movement duration
   options = optimset('Display','off','MaxFunEvals',100000,'MaxIter',100000);
   [sol,fval,exitflag,output] = fmincon(@utility,[0],[],[],[],[],[0],[],[],options); %using fmincon, second [0,0] is a lower bound on guesses
   mysols(i,1) = sol;
   myJs(i,1) = -1*utility(sol);
   
   % compute new fatigue
   e = Er(sol, param.mya, param.myb); % effort of optimal reach
   r = rwd(param.r, sol, param.myc0, param.myc1); % rwd of optimal reach
   [rfnew, ufnew] = fatigue_fun(param.rfprev, param.ufprev, e, r, param.alpha, param.delta, param.theta);
   rfuf(i+1, 1) = rfnew;
   rfuf(i+1, 2) = ufnew;
   
end

%% Plot subjective value, P(work), and fatigue states

% smooth splines fits to show avg. trends
j = fit(trials,myJs,'smoothingspline','SmoothingParam',0.1); % lower param = smoother
s = fit(trials,mysols,'smoothingspline','SmoothingParam',0.1);

%% Mesh grid plotting P(work) as a function of reward-effort options
% unq = unique(work,'rows');
% cmap = zeros([5 5]);
% cmap1 = zeros([5 5]);
% cmap2 = zeros([5 5]);
% 
% for i = 1:length(unq)
%     combo = unq(i,:);
%     A = find(ismember(work,combo,'rows'));
%     aggprobs(i,1) = mean(probs(A));
%     probs1(i,1) = mean(probs(A(1:2)));
%     probs2(i,1) = mean(probs(A(end-1:end)));
%     cmap(i) = aggprobs(i,1);
%     cmap1(i) = probs1(i,1);
%     cmap2(i) = probs2(i,1);
% end
% unq = [unq,aggprobs];
    
%% Combined plot
figure;
subplot(3,1,1)
    plot(trials, myJs,'-o', 'Marker', '.');
    hold on
    yl = ylim;
    plot(trials,j(trials), 'HandleVisibility', 'off');
    xlabel("Trial"); ylabel("Utility (J/s)");

subplot(3,1,2)
    plot(trials, mysols, '-o', 'Marker', '.');
    hold on
    yline(0.5, 'k--', 'LineWidth',0.5, 'Alpha',0.5)
    yl = ylim;
    plot(trials,s(trials), 'HandleVisibility', 'off')
    xlabel("Trial"); ylabel("Movement duration (s)");

subplot(3,1,3)
    plot(trials, rfuf(1:end-1, 1), trials, rfuf(1:end-1,2), '-o', 'Marker', '.');
    xlabel("Trial"); ylabel("Fatigue level"); legend("RF", "UF");

% subplot(4,2,7)
%     imagesc((rwds), (effs), cmap1');
%         colormap bone %winter, summer, gray, cool, bone, copper, pink
%         caxis([0 max(probs)]) % should scale colorbar to be the same between plots
%         xlabel('Reward (credits)'); 
%         ylabel('Effort (% MVC)');
%         title('First 2 decisions');
%         set(gca, 'YTick',effs,'YTickLabels',effs./mvc.*100,...
%             'XTick',rwds,'XTickLabels',rwds)
% subplot(4,2,8)
%     imagesc((rwds), (effs), cmap2');
%         colormap bone %winter, summer, gray, cool, bone, copper, pink
%         caxis([0 max(probs)])  % should scale colorbar to be the same between plots
%         xlabel('Reward (credits)'); 
%         ylabel('Effort (% MVC)');
%         title('Last 2 decisions');
%         set(gca, 'YTick',effs,'YTickLabels',effs./mvc.*100,...
%             'XTick',rwds,'XTickLabels',rwds)

