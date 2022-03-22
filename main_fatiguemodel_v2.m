% Recreating the fatigue-weighted subjective value model from Muller et
% al., 2021
%   Supplementary info for paper: https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-021-24927-7/MediaObjects/41467_2021_24927_MOESM1_ESM.pdf

clear all 

% set seed
rng(69) 

%% Initialize parameters
global param

trials = [1:250]'; % simulate 250 trials
% mvc = 5;
% rwds = 2:2:10; % rewards, from paper
% effs = mvc.*[.30 .39 .48 .57 .66]; % %MVC effort, from paper
% effs = 2:2:10;
% Trest = 5; % Rest period. Longer rests result in higher proportion of decisions to work

% Initialize subject-specific parameters (between 0 and 1.1)
param.k = 0.065; % discounting, restrict to not go below 0.0276 (0.065 is approx. mean from supplementary info)
param.alpha = .3; % RF effort scale (approx. mean = 0.3) - increasing this causes less decisions to work
param.delta = .25; % Reward scale (approx. mean = 0.25) - increasing this causes more decisions to work
param.theta = 0.018; % UF effort scale (approx. mean = 0.018) - increasing this causes less decisions to work
param.beta = 0.005; % controls how rapidly the fatigue scaling factor (fat) increases
param.gamma = 0.45;

% Initialize movement-specific parameters
param.myc0 = -5; % accuracy parameters; shifts logistic to the right with scaling
param.myc1 = 10; % accuracy parameters; shifts logistic to the left with scaling
param.mya = 77; % effort offset (77)
param.myb = 12; %b in metabolic equation (new = 11) (1.2)
param.myi=1.23;  %exponent on distance
param.myeffscale = 1; 
param.myrwdscale = 1;

% Initialize decision landscape
% options = combvec(effs, rwds)';
% work = datasample(repmat(options,10,1),length(trials),1,'Replace',false); % effort and reward choices
% rest = [zeros([length(trials),1]), ones([length(trials),1])]; % rest option: 0 effort, 1 reward

% initialize storage arrays
mysols = zeros([length(trials),1]);
myJs = zeros([length(trials),1]);
rfuf = ones([length(trials)+1, 3]); %RF col 1, UF col 2. Initial values = 0 from paper
myes = zeros([length(trials),1]);
myrs = zeros([length(trials),1]);
param.fat = 0;

%range of alpha values
val = 70; % reward value
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
       param.fat = rfuf(i,3);
   
   % Find optimal movement duration
       options = optimset('Display','off','MaxFunEvals',100000,'MaxIter',100000);
       [sol,fval,exitflag,output] = fmincon(@utility,[0],[],[],[],[],[0],[],[],options); %using fmincon, second [0,0] is a lower bound on guesses
       mysols(i,1) = sol;
       myJs(i,1) = -1*utility(sol);
   
   % compute e and r at optimal movement duration
       e = Er(sol, param.mya*param.myeffscale, param.myb*param.myeffscale); % effort of optimal reach
       myes(i,1) =  e;
       r = rwd(param.r*param.myrwdscale, sol, param.myc0, param.myc1); % rwd of optimal reach
       myrs(i,1) = r;
   % compute updated fatigue
       [rfnew, ufnew, fat] = fatigue_fun(param.rfprev, param.ufprev, e, r, param.alpha, param.delta, param.theta);
       rfuf(i+1, 1) = rfnew;
       rfuf(i+1, 2) = ufnew;
       rfuf(i+1, 3) = fat;
       param.myrwdscale = (1+fat)/2;
       param.myeffscale = 2/(1+fat);

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
subplot(4,1,1)
    yyaxis right
    plot(trials, myalphas, '--');
    hold on
    plot(trials, myrs,'-o', 'Marker','.');
    ylim([-inf myalphas(1)+10]);
    ylabel('Reward (J)'); 
    yyaxis left
    plot(trials,myes,'-o', 'Marker','.');
    xlabel("Trial"); ylabel("Effort (J)");
    legend('Effort', 'Alpha', 'S.V.')

subplot(4,1,2)
    plot(trials, myJs,'-o', 'Marker', '.');
    hold on
    plot(trials,j(trials), 'HandleVisibility', 'off');
    xlabel("Trial"); ylabel("Utility (J/s)");

subplot(4,1,3)
    plot(trials, mysols, '-o', 'Marker', '.');
    hold on
    yl = ylim;
    plot(trials,s(trials), 'HandleVisibility', 'off')
    xlabel("Trial"); ylabel("Movement duration (s)");

subplot(4,1,4)
    plot(trials, rfuf(1:end-1,1), '-o', 'Marker', '.')
    hold on
    plot(trials, rfuf(1:end-1,2), '-o', 'Marker', '.');
    xlabel("Trial"); ylabel("Fatigue");
    legend("RF","UF")

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

