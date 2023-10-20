function run_analysis_step2(analysis_folder,animal_folder_listing)

af_name = animal_folder_listing(ii).name;
af_path = fullfile(analysis_folder,af_name);
fprintf('Animal: %s\n',af_path);

%LIST ALL RECORING SESSIONS FOR ONE ANIMAL
recording_listing =  dir([af_path filesep '*step1.mat']);
rec_all_list = [rec_all_list;recording_listing];
for j=1:size(recording_listing,1)
    if ~exist([recording_listing(j).folder filesep recording_listing(j).name(1:(end-5)) '2.mat'] ,'file')
        %load step1 data
        load(fullfile(recording_listing(j).folder,recording_listing(j).name));
        step1 = analysis_step2(step1);
        disp('Done step2')
    else
        load ([recording_listing(j).folder filesep recording_listing(j).name(1:(end-5)) '2.mat'])
        if isfield(step2,'go_run')
            datatype(count).t = 'run';
            disp('run')
        elseif isfield(step2,'go_eat')
            datatype(count).t = 'eat';
            disp('eat')
        end
        count = count+1;
        disp('Already done step2')
    end
end

end