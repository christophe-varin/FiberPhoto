function run_analysis_step1(data_folder,analysis_folder,animal_folder_listing)

af_name = animal_folder_listing(ii).name;
af_path = fullfile(data_folder,af_name);
fprintf('Animal: %s\n',af_path);

% CREATES AN ANIMAL FOLDER IN THE ANALYSIS DIRECTORY (analysis_af)
analysis_af_name = fullfile(analysis_folder,af_name);
if ~exist(analysis_af_name, 'file')
    mkdir(analysis_af_name)
end

%LIST ALL RECORING SESSIONS FOR ONE ANIMAL
recording_listing =  dir([af_path filesep '*.csv']);
for j=1:size(recording_listing,1)
    avi_filename = recording_listing(j).name;
    avi_path = fullfile(af_path,avi_filename);
    fprintf('-->Recording: %s\n',avi_filename);

    step1 = s_model;
    step1.session = data_tools.parse_filename(avi_filename);
    step1.data.folder = af_path;
    step1.figure.folder = analysis_af_name;
    step1.figure.prefix = step1.session.prefix;
    step1.debug.prefix = step1.figure.prefix;

    doric_csv_path = [af_path filesep step1.figure.prefix '.csv'];

    do_it = 0;

    if ~exist([step1.figure.folder filesep step1.figure.prefix '_step1.mat'],'file')
        step1 = analysis_step1(doric_csv_path, step1);
        disp('Done step1')
    else
        %update path
        save_step1 = step1;
        load([step1.figure.folder filesep step1.figure.prefix '_step1.mat'])
        step1.figure.folder = save_step1.figure.folder;
        step1.debug.folder = save_step1.debug.folder;
        step1.data.folder = save_step1.data.folder;
        save([step1.figure.folder filesep step1.figure.prefix '_step1.mat'],'step1');
        disp('Already calculated')
    end


end


end
