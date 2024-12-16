%%

%data10ms = MM_S1_data10ms; 
%data10ms = MT_S1_data10ms;
%data10ms = MT_S2_data10ms;
data10ms = MT_S3_data10ms;

num_reaches = length(data10ms.Data.neural_data_PMd);  
num_neurons = size(data10ms.Data.neural_data_PMd{1}, 1);
total_time_steps = sum(cellfun(@(x) size(x, 2), data10ms.Data.neural_data_PMd));
N_Obs = zeros(num_neurons, total_time_steps);
current_index = 1; 
for reach_idx = 1:num_reaches
    reach_spikes = data10ms.Data.neural_data_PMd{reach_idx};  
    num_time_steps = size(reach_spikes, 2);
    N_Obs(:, current_index : current_index + num_time_steps - 1) = reach_spikes;
    current_index = current_index + num_time_steps;
end

disp(['Total number of timestamps in N_Obs: ', num2str(size(N_Obs, 2))]);  % Should match 59742


%%
[~, num_columns] = size(N_Obs);
Y_Obs = zeros(1, num_columns);

%%
num_reaches = length(data10ms.Data.neural_data_PMd);  
num_neurons = size(data10ms.Data.neural_data_PMd{1}, 1);
total_time_steps = sum(cellfun(@(x) size(x, 2), data10ms.Data.neural_data_PMd));  
Y_Obs = zeros(num_neurons, total_time_steps); 
current_index = 1;  
for reach_idx = 1:num_reaches-1
    reach_LFP = data10ms.Data.neural_data_PMd{reach_idx}; 
    num_time_steps_50ms = size(reach_LFP, 2);
    num_time_steps_10ms = size(data10ms.Data.neural_data_PMd{reach_idx}, 2); 
    LFP_interpolated = interp1(1:num_time_steps_50ms, reach_LFP', linspace(1, num_time_steps_50ms, num_time_steps_10ms))';    
    Y_Obs(:, current_index : current_index + num_time_steps_10ms - 1) = LFP_interpolated;

    current_index = current_index + num_time_steps_10ms;
end

disp(['LFP data size (Y_Obs): ', num2str(size(Y_Obs))]);  % Should match updated N_Obs size (67 x 59742)


%%

handles = struct;
handles.dim_hid = 8; 
handles.scale_dif_inp = 1;  
handles.delta_inp = 0.05; 
handles.num_iter = 25; 
handles.switch_nondiagQ = 0; 
handles.switch_nondiag = 0; 
handles.init_type = 'random';  
handles.switch_biasobs = 0;  
handles.save_iter = 'startandend';  
handles.spike_bs_init = 'random';  
handles.number_systems = 1; 
handles.dim_Y = 1;


%%
[resultsEM, settings, ITER] = EM_multiscale_unsupervised_function(Y_Obs, N_Obs, handles);
%%
X_smoothed = resultsEM.X_smoothed;
save('X_smoothed.mat', 'X_smoothed');
kinematics_data = data10ms.Data.kinematics;  
num_reaches = length(kinematics_data);  
total_time_steps = sum(cellfun(@(x) size(x, 1), kinematics_data)); 
kinematics_collated = zeros(4, total_time_steps); 
current_index = 1; 
for reach_idx = 1:num_reaches
    reach_kinematics = kinematics_data{reach_idx};  
    num_time_steps = size(reach_kinematics, 1);
    reach_kinematics_4 = reach_kinematics(:, 1:4); 
    kinematics_collated(:, current_index:current_index + num_time_steps - 1) = reach_kinematics_4';
    current_index = current_index + num_time_steps;
end
disp(['Collated kinematics data size: ', num2str(size(kinematics_collated))]);  
save('kinematics_collated.mat', 'kinematics_collated');

disp('End');




