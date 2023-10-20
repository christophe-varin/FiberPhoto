

steps2run = [false false true];

%folder containing doric data and boris data
%one subfolder per animal with all trials from the same animal
data_folder = fullfile(pwd,'Data'); 
%folder used to save analyses
%one subfolder per animal with all trials from the same animal
analysis_folder = fullfile(pwd,'Analysis'); %

%init struct for analyses
s_model = data_tools.init_model(analysis_folder);

%get list of mice folders
animal_folder_listing = dir(data_folder);
animal_folder_listing = animal_folder_listing(~strcmp({animal_folder_listing.name},'.')&~strcmp({animal_folder_listing.name},'..'));

%%% RUN STEP1: extraction of photometry signals
if steps2run(1)
    for ii = 1:size(animal_folder_listing,1) %loop on mice
        run_analysis_step1(data_folder,analysis_folder,animal_folder_listing)
    end
else
    disp('step1 skipped')
end

%%% RUN STEP2: extract photometry signals vs boris behavior events

if steps2run(2)
    rec_all_list = []; count = 1; datatype = [];
    for ii = 1:size(animal_folder_listing,1)
        run_analysis_step2(analysis_folder,animal_folder_listing)
    end
else
    disp('step2 skipped')
end

%%% STEP 3: assemble all data into one single dataset

geno_names = {'D1','D2'};
rec_type = {'eat','run'};
%list of events and corresponding full names
events_names = {'door_eat','go_eat','eat','door_run','go_run','w_on','w_on2','w_off','w_blk','plt1'};
events_display = {'Feeding room access','Go eat','Start feeding','Running room access','Go run','First run','Start running','Stop running','Locked wheel','First pellet consumption'};
%time windows around events for peri-event calculation
wind_pst = [-40 100; -40 100; -8 8; -40 100; -40 100; -40 100; -8 8; -8 8; -50 50; -40 100]';

if steps2run(3)
    clear step1 step2 Dataset
    Dataset = data_tools.generate_dataset(animal_folder_listing,analysis_folder,geno_names,rec_type,events_names);
else
    disp('step3 skipped')
    try 
        %reload dataset if step skipped
        load(fullfile(analysis_folder,'Dataset.mat'))
        disp('Dataset loaded')
    catch
        disp('ERROR: Dataset.mat file not found')
        return
    end
end

%%%%%%%%%%

%%% ANALYSES

% HEAT MAP PHOTOMETRY SIGNAL ENTIRE SESSION 

events_names = {'door_eat','go_eat','eat','door_run','go_run','w_on','w_on2','w_off','w_blk','plt1'};
events_display = {'Feeding room access','Go eat','Start feeding','Running room access','Go run','First run','Start running','Stop running','Locked wheel','First pellet consumption'};
events_plot = {'x','o','v','x','o','>','>','<','x','+'};
geno_names = {'D1','D2'};
rec_type = {'eat','run'};
tot_trials_plot = 100; % take the 'tot_trials_plot' first trials

plot_tools.plot_heat_maps(Dataset,geno_names,rec_type,events_names,events_plot)
    

%ANALYSIS BETWEEN CONDITIONS

%set parameters
nb_bootstrap = 2000; %number of random resampling
alpha_sig = 0.05; %significance level
fps = 10; %acquisition rate 10 Hz
consecutive_points = round(1*fps); %during 1 s, consecutive threshold required to control for Type I errors inflation caused by signal noise

%compute CIs for each condition and significance difference vs 0
CI_events = cell(size(Dataset.events.data));
Sig_events = cell(size(Dataset.events.data));
CI_events_bsl = cell(size(Dataset.events.data));
Sig_events_bsl = cell(size(Dataset.events.data));
for ee=1:1:size(Dataset.events.data,1)
    for gg=1:1:length(geno_names)
        CI_events{ee,gg} = mean(Dataset.events.data{ee,gg},'omitnan');
        [CI_events{ee,gg}([2,3],:),Sig_events{ee,gg}] = data_tools.compute_CI(Dataset.events.data{ee,gg},nb_bootstrap,alpha_sig,consecutive_points);
    end
end

%compare if differences between genotypes D1 vs D2 around each event
plot_Xlimits = repmat([-Inf Inf],length(events_names),1);
plot_Xlimits(strcmp(events_display,'First pellet consumption'),:) = [-Inf 60];
plot_Xlimits(strcmp(events_display,'First run'),:) = [-Inf 60];
AUC_limits = repmat([-20 0 0 60],length(events_names),1);
AUC_limits(strcmp(events_display,'Start feeding'),:) = [-4 0 0 4];
AUC_limits(strcmp(events_display,'Start running'),:) = [-4 0 0 4];
AUC_limits(strcmp(events_display,'Stop running'),:) = [-4 0 0 4];
AUC_limits(strcmp(events_display,'Locked wheel'),:) = [-4 0 0 4];
for ee=1:1:size(CI_events,1)
    plot_tools.plot_differences_geno(Dataset,CI_events,Sig_events,ee,plot_Xlimits,AUC_limits)
end







