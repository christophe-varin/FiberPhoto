function Dataset = generate_dataset(animal_folder_listing,analysis_folder,geno_names,rec_type,events_names)

Dataset.info.geno_names = geno_names;
Dataset.info.rec_types = rec_type;
Dataset.info.mice_list = cell(length(rec_type),length(geno_names));
Dataset.whole_dff.data = cell(length(rec_type),length(geno_names));
Dataset.whole_dff.info = cell(length(rec_type),length(geno_names));
Dataset.whole_dff.tags = cell(length(rec_type),length(geno_names));
Dataset.events.data = cell(length(events_names),length(geno_names));
Dataset.events.data_bsl = cell(length(events_names),length(geno_names));
Dataset.events.transient = cell(length(events_names),length(geno_names));
Dataset.events.time = cell(length(events_names),length(geno_names));
Dataset.events.info_mice = cell(length(events_names),length(geno_names));
Dataset.events.info_trial = cell(length(events_names),length(geno_names));
Dataset.events.info_trial_order = cell(length(events_names),length(geno_names));
Dataset.events.events_names = events_names;
Dataset.events.events_display = events_display;
for ii=1:1:length(animal_folder_listing) %loop on mice
    curr_geno = find(strcmp(animal_folder_listing(ii).name((end-1):end),geno_names));
    disp(['ii=',num2str(ii),' / currgeno=',num2str(curr_geno)])
    %gent list of step2 files
    recording_listing =  dir([analysis_folder filesep animal_folder_listing(ii).name filesep '*step2.mat']);
    for jj=1:1:length(recording_listing) %loop on sessions
        load(fullfile(recording_listing(jj).folder,recording_listing(jj).name))
        disp(step1.session.prefix)
        if isfield(step2,'door_eat') %find if eat session
            curr_rec = 1;
            Dataset.whole_dff.info{curr_rec,curr_geno} = [Dataset.whole_dff.info{curr_rec,curr_geno},{step2.door_eat.session_info.mouse;step2.door_eat.session_info.trial}];
            event_bsl_mean = step2.door_eat.event_bsl_mean; event_bsl_std = step2.door_eat.event_bsl_std;
        elseif isfield(step2,'door_run') %or run session
            curr_rec = 2;
            Dataset.whole_dff.info{curr_rec,curr_geno} = [Dataset.whole_dff.info{curr_rec,curr_geno},{step2.door_run.session_info.mouse;step2.door_run.session_info.trial}];
            event_bsl_mean = step2.door_run.event_bsl_mean; event_bsl_std = step2.door_run.event_bsl_std;
        end

        %full session photometry
        Dataset.whole_dff.data{curr_rec,curr_geno} = [Dataset.whole_dff.data{curr_rec,curr_geno},NaN(3500,1)];
        Dataset.whole_dff.data{curr_rec,curr_geno}(1:length(step1.dff),end) = step1.dff;

        tags = zeros(3500,1);

        %binarized transient position
        df = round(mean(diff(step1.transients.loc(:))./diff(step1.transients.time(:))));
        time_whole = (0:1:(length(tags)-1))/df;
        transient_whole = tags; transient_whole(step1.transients.loc) = 1;

        for ee=1:1:length(events_names)
            if isfield(step2,events_names{ee})
                %get photometry signal for each event
                Dataset.events.time{ee,curr_geno} = step2.(events_names{ee}).x/1000; % in sec
                Dataset.events.data{ee,curr_geno} = [Dataset.events.data{ee,curr_geno}; step2.(events_names{ee}).dff_PETA.zscored_matrix];
                Dataset.events.info_mice{ee,curr_geno} = [Dataset.events.info_mice{ee,curr_geno}; repmat({step1.session.mouse},size(step2.(events_names{ee}).dff_PETA.zscored_matrix,1),1)];
                Dataset.events.info_trial{ee,curr_geno} = [Dataset.events.info_trial{ee,curr_geno}; repmat({step1.session.trial},size(step2.(events_names{ee}).dff_PETA.zscored_matrix,1),1)];
                %get timestamps of events for full session signal
                tags(step2.(events_names{ee}).center_idx) = ee;
                for zz=1:1:length(step2.(events_names{ee}).center_idx)
                    curr_id = step2.(events_names{ee}).center_idx(zz);
                    temp = (step1.dff(round(curr_id+wind_pst(1,ee)*10):round(curr_id+wind_pst(2,ee)*10))-event_bsl_mean)/event_bsl_std;
                    %photometry signal with z-score over baseline period
                    Dataset.events.data_bsl{ee,curr_geno} = [Dataset.events.data_bsl{ee,curr_geno}; temp'];
                    %ts of transients
                    time_lagged = time_whole-time_whole(curr_id);
                    temp = transient_whole(round(curr_id+wind_pst(1,ee)*10):round(curr_id+wind_pst(2,ee)*10));
                    Dataset.events.transient{ee,curr_geno} = [Dataset.events.transient{ee,curr_geno}; temp'];
                end
            end
        end
        Dataset.whole_dff.tags{curr_rec,curr_geno} = [Dataset.whole_dff.tags{curr_rec,curr_geno},tags];
    end
end
for gg=1:1:length(geno_names)
    for rr=1:1:length(rec_type)
        %info of mouse name and sessions
        Dataset.info.mice_list{rr,gg} = unique(Dataset.whole_dff.info{rr,gg}(1,:));
        for mm=1:1:length(unique(Dataset.whole_dff.info{rr,gg}(1,:)))
            Dataset.info.mice_list{rr,gg}{2,mm} = sum(strcmp(Dataset.whole_dff.info{1,1}(1,:),Dataset.info.mice_list{rr,gg}{1,mm}));
        end
    end
    %generate list of trials order as auto sorting is messy (eg Trial11 ends up before Trial9)
    ordered_trials = cell(5*15,1); count = 1;
    for aa=1:1:15
        for bb=1:1:5
            ordered_trials{count} = ['T',num2str(aa),'Rec',num2str(bb)]; count = count+1;
        end
    end
    for ee=1:1:size(Dataset.events.info_mice,1)
        Dataset.events.info_trial_order{ee,gg} = NaN(size(Dataset.events.info_mice{ee,gg}));
        list_mice = unique(Dataset.events.info_mice{ee,gg});
        for mm=1:1:length(list_mice)
            curr_ind = strcmp(Dataset.events.info_mice{ee,gg},list_mice{mm});
            list_trials = Dataset.events.info_trial{ee,gg}(curr_ind);
            ordered = NaN(size(list_trials)); count = 1;
            for tt=1:1:length(ordered_trials)
                if ~isempty(find(strcmp(list_trials,ordered_trials{tt}),1))
                    ordered(strcmp(list_trials,ordered_trials{tt})) = count; count = count+1;
                end
            end
            Dataset.events.info_trial_order{ee,gg}(curr_ind) = ordered;
        end
    end

end
if ~isfolder(fullfile(pwd,'Results'))
    mkdir(fullfile(pwd,'Results'));
end
%save dataset
save(fullfile(pwd,'Results','Dataset.mat'),'Dataset','-v7.3');
    
end
