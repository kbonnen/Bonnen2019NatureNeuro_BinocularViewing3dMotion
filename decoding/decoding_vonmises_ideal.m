addpath('../helperFunctions/');
% load data
clear;
close all;
fn ='decoding_vonmises_ideal/vonmises_ideal';
% create parameters

N = 236;
params = [ (1/N:1/N:1)'*360, ones(N,1), 15+30*rand(N,1),30*rand(N,1)];

% generate data
theta = (0:2*(pi/180):2*pi)';   % motion direction (radians) (usually 0:pi/180:2*pi, every degree)
speed = 20;
m = speed * ones(size(theta));  % speed (cm/s)
x = [theta,m];                  % motion direction/speed
nTrials = 10;                   % usually 100

data = nan(N,nTrials,length(theta));
for i=1:nTrials
    data(:,i,:) = poissrnd(f_vonmisespdf(x,params));
end

%%
% for each trial   
%   calculate the population log likelihood across all theta

d_theta_poss = pi/180; % radians
theta_poss = (0:d_theta_poss:2*pi)';
x_poss = [theta_poss,speed*ones(size(theta_poss))]; 
pop = nan(length(theta_poss),nTrials,length(theta));
weights = nan(N,length(theta_poss));

for i=1:length(theta)
    tic;
    for j=1:nTrials
        [pop(:,j,i),weights(:,:)] = ...
            popLogLikelihood(x_poss,@f_vonmisespdf,data(:,j,i),params);
    end
    fprintf('%i: %2f\n',i,toc);
end

save(fn);

%%
% load(fn);

[~,estimates] = max(pop,[],1);                      % maximum log-likelihood
estimates = (squeeze(estimates)'-1)*d_theta_poss;   % convert from index value to radians

% plot away
figure(3);
plot(rad2deg(theta),rad2deg(estimates),'k.');

set(gca,'XTick',0:90:360,'YTick',0:90:360,'FontSize',20);
xlabel('presented motion direction (deg.)'); ylabel('model prediction (deg.)');
xlim([-5,365]);
ylim([-5,365]);
axis square
box off;

% 
set(gcf, 'PaperPosition', [0,0,3.5,1.4]); %Position the plot further to the left and down. Extend the plot to fill entire paper.[left bottom width height]
set(gcf, 'PaperSize', [3.5,1.4]); 
saveas(gcf,fn,'pdf');