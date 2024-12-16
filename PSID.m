%% PSID

% Y data
%data50ms = MM_S1_data50ms; 
%data50ms = MT_S1_data50ms;
%data50ms = MT_S2_data50ms;
data50ms = MT_S3_data50ms;

all_reaches = length(data50ms.neural_data_PMd); 
y = [];  


for reach_idx = 1:all_reaches
    reach_data = data50ms.neural_data_PMd{reach_idx};
    y = [y; reach_data'];  
end

disp(size(y));  
%% Z data
all_reaches = length(data50ms.kinematics); 
z = [];  
for reach_idx = 1:all_reaches
    reach_data = data50ms.kinematics{reach_idx};
    reach_data = reach_data(:, 1:4); 
    z = [z; reach_data];  
end

disp(size(z)); 
%%
% Define the parameters
nx = 30;   % Total latent states
n1 = 4;    % Behaviorally relevant states
i = 5;     % Subspace horizon
idSys = PSID(y, z, nx, n1, i);

%%
[zPred, yPred, xPred] = PSIDPredict(idSys, y);

%%
save('zPred.mat','zPred');
save('z.mat','z');
