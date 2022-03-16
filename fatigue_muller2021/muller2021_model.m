% Recreating the fatigue-weighted subjective value model from Muller et
% al., 2021
%   Supplementary info for paper: https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-021-24927-7/MediaObjects/41467_2021_24927_MOESM1_ESM.pdf

% set seed
rng(123) 

% Initialize parameters
t = [1:250]'; % simulate 250 trials
mvc = 10;
rwds = 2:2:10; % rewards, from paper
effs = mvc.*[.30 .39 .48 .57 .66]; % %MVC effort, from paper
Trest = 5; % Rest period. Longer rests result in higher proportion of decisions to work

% Initialize subject-specific parameters (between 0 and 1.1)
beta = 0.25; % stochasticity of choices, restricted to > 0 
k = 0.065; % discounting, restrict to not go below 0.0276 (0.065 is approx. mean from supplementary info)
alpha = 0.3; % RF work scale (approx. mean = 0.3) - increasing this causes less decisions to work
delta = 0.25; % RF rest scale (approx. mean = 0.25) - increasing this causes more decisions to work
theta = 0.018; % UF effort scale (approx. mean = 0.018) - increasing this causes less decisions to work

% Initialize decision landscape
options = combvec(effs, rwds)';
work = datasample(repmat(options,10,1),length(t),1,'Replace',false); % reward and effort choices
rest = [ones([length(t),1]), zeros([length(t),1])]; % rest options, 1 rwd for 0 effort

% initialize storage arrays
SVs = zeros([length(t),1]);
probs = zeros([length(t),1]);
decs = zeros([length(t),1]);
fat = zeros([length(t)+1, 2]); %RF col 1, UF col 2. Initial values = 0 from paper

% Loop and make decisions
for i = 1:length(t)
   % Presented reward-effort option 
   e = work(i,1);
   r = work(i,2);
   
   % Prior fatigue
   rfprev = fat(i,1);
   ufprev = fat(i,2);
   
   % Calculate SV of work
   SVs(i) = SV(r, e, rfprev, ufprev, k);
   
   % calculate P(work) using SV
   probs(i) = softmaxP(SVs(i), beta);
   
   % Make decision to work or not
   if probs(i) > 0.5 % choose to work
       dec = 1;
   else % rest
       dec = nan;
       e = 0;
       r = 1;
   end
   decs(i) = dec;
   
   % compute new fatigue
   rfnew = RF(rfprev, dec, e, Trest, alpha, delta);
   ufnew = UF(ufprev, e, theta);
   
   fat(i+1, 1) = rfnew;
   fat(i+1, 2) = ufnew;
   
end

%% Plot subjective value, P(work), and fatigue states

% smooth splines fits to show avg. trends
f = fit(t,SVs,'smoothingspline','SmoothingParam',0.1); % lower param = smoother
p = fit(t,probs,'smoothingspline','SmoothingParam',0.1);

% figure;
% subplot(3,1,1)
%     plot(t, SVs);
%     hold on
%     plot(f)
%     yl = ylim;
%     plot(t,yl(1).*decs, 'r|', 'MarkerFaceColor', 'r', 'MarkerSize', 5); 
%     xlabel("Trial"); ylabel("Subjective Value");
% 
% subplot(3,1,2)
%     plot(t, probs);
%     hold on
%     plot(p)
%     yline(0.5, 'k-', 'LineWidth',0.5)
%     yl = ylim;
%     plot(t,yl(1).*decs, 'r|', 'MarkerFaceColor', 'r', 'MarkerSize', 5);
%     xlabel("Trial"); ylabel("P(work)");
% 
% subplot(3,1,3)
%     plot(t, fat(2:end, 1), t, fat(2:end,2));
%     xlabel("Trial"); ylabel("Fatigue level"); legend("RF", "UF");

%% Mesh grid plotting P(work) as a function of reward-effort options
unq = unique(work,'rows');
cmap = zeros([5 5]);
cmap1 = zeros([5 5]);
cmap2 = zeros([5 5]);

for i = 1:length(unq)
    combo = unq(i,:);
    A = find(ismember(work,combo,'rows'));
    aggprobs(i,1) = mean(probs(A));
    probs1(i,1) = mean(probs(A(1:2)));
    probs2(i,1) = mean(probs(A(end-1:end)));
    cmap(i) = aggprobs(i,1);
    cmap1(i) = probs1(i,1);
    cmap2(i) = probs2(i,1);
end
unq = [unq,aggprobs];

% figure
% imagesc((rwds), (effs), cmap');
%     colormap bone %winter, summer, gray, cool, bone, copper, pink
%     c = colorbar;
%     c.Label.String = 'P(Work)';
%     xlabel('Reward (credits)'); 
%     ylabel('Effort (% MVC)');
%     set(gca, 'YTick',effs,'YTickLabels',effs./mvc.*100)
%     
% figure 
% subplot(1,2,1)
% imagesc((rwds), (effs), cmap1');
%     colormap bone %winter, summer, gray, cool, bone, copper, pink
%     caxis([0 max(probs)]) % should scale colorbar to be the same between plots
%     xlabel('Reward (credits)'); 
%     ylabel('Effort (% MVC)');
%     set(gca, 'YTick',effs,'YTickLabels',effs./mvc.*100,...
%     'XTick',rwds,'XTickLabels',rwds)
% subplot(1,2,2)
% imagesc((rwds), (effs), cmap2');
%     colormap bone %winter, summer, gray, cool, bone, copper, pink
%     caxis([0 max(probs)])  % should scale colorbar to be the same between plots
%     xlabel('Reward (credits)'); 
%     ylabel('Effort (% MVC)');
%     set(gca, 'YTick',effs,'YTickLabels',effs./mvc.*100,...
%     'XTick',rwds,'XTickLabels',rwds)
    
%% Looking at effect of beta on softmax function
% figure
% for i = 0:0.1:1.0
%     beta = i;
%     pwork = @(x) (exp(x.*beta))./(exp(beta) + exp(x.*beta));
%     f = fplot(pwork, 'LineWidth', 1, 'DisplayName', sprintf('\\beta = %0.1f',i)); 
%     hold on
%     f.Color = i.*[0 1 0];
%     xlabel('Subjective Value'); ylabel('P(work)');
%     legend("show", "Location", "southeast");
% end
    
%% Combined plot
figure;
subplot(4,2,[1,2])
    plot(t, SVs,'-o', 'Marker', '.');
    hold on
    yl = ylim;
    plot(t,yl(1).*decs, 'r|', 'MarkerFaceColor', 'r', 'MarkerSize', 5); 
    plot(f);
    xlabel("Trial"); ylabel("Subjective Value");

subplot(4,2,[3,4])
    plot(t, probs, '-o', 'Marker', '.');
    hold on
    yline(0.5, 'k--', 'LineWidth',0.5, 'Alpha',0.5)
    yl = ylim;
    plot(t,yl(1).*decs, 'r|', 'MarkerFaceColor', 'r', 'MarkerSize', 5);
    plot(p)
    xlabel("Trial"); ylabel("P(work)");

subplot(4,2,[5,6])
    plot(t, fat(1:end-1, 1), t, fat(1:end-1,2), '-o', 'Marker', '.');
    xlabel("Trial"); ylabel("Fatigue level"); legend("RF", "UF");

subplot(4,2,7)
    imagesc((rwds), (effs), cmap1');
        colormap bone %winter, summer, gray, cool, bone, copper, pink
        caxis([0 max(probs)]) % should scale colorbar to be the same between plots
        xlabel('Reward (credits)'); 
        ylabel('Effort (% MVC)');
        title('First 2 decisions');
        set(gca, 'YTick',effs,'YTickLabels',effs./mvc.*100,...
            'XTick',rwds,'XTickLabels',rwds)
subplot(4,2,8)
    imagesc((rwds), (effs), cmap2');
        colormap bone %winter, summer, gray, cool, bone, copper, pink
        caxis([0 max(probs)])  % should scale colorbar to be the same between plots
        xlabel('Reward (credits)'); 
        ylabel('Effort (% MVC)');
        title('Last 2 decisions');
        set(gca, 'YTick',effs,'YTickLabels',effs./mvc.*100,...
            'XTick',rwds,'XTickLabels',rwds)

