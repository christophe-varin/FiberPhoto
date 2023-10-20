function step1=analysis_step2(step1)
%% LOADING REQUIERED DATA

tsvfilename = [step1.data.folder filesep step1.session.prefix '.tsv'];
boris_data = boris_tools.load_boris_aggregated_data(tsvfilename,step1.dio3.raising_times);
boris_data = boris_tools.rename_roman_events(boris_data);

%% PARAMETERS
%%before_msec = step1.psth.before_msec;
%%after_msec  = step1.psth.after_msec;
%%baseline_period_start_msec = step1.psth.baseline_period_start_msec;
%%baseline_period_stop_msec = step1.psth.baseline_period_stop_msec;
%%transient_histo_bin_size_msec = step1.psth.transient_histo_bin_size_msec;

% estimate the number of event categories
n_events = size(boris_data.events,2);

before_msec = -30000;
after_msec = 50000;
before_msec_transient = -55000;
after_msec_transient = 55000;
baseline_period_start_msec = -15000;
baseline_period_stop_msec = -20000;
baseline_period_start_msec_transient = -50000;
baseline_period_stop_msec_transient = 0;
transient_histo_bin_size_msec = 250;
transient_histo_edges_msec = before_msec:transient_histo_bin_size_msec:after_msec;
transient_histo_edges_msec_bis = before_msec_transient:transient_histo_bin_size_msec:after_msec_transient;

basal = {'Basal'};
eat_event = {'door_eat','go_eat','plt1'};
run_event = {'door_run','go_run','w_on'};
short_event = {'eat','w_on2','w_off','w_blk'};
Locked_event = {}; 

% Loop on each event category
for i_event = 1:n_events
     
    Eventname = [boris_data.events(i_event).name];

    if ismember(Eventname,basal)
        before_msec = -10000;
        after_msec = 10000;
        baseline_period_start_msec = -10000;
        baseline_period_stop_msec = 10000;
        evt_ts_start = boris_data.events(i_event).start;
        evt_ts_stop = boris_data.events(i_event).stop;
        evt_basal_size = evt_ts_stop-evt_ts_start;
        center_basal_evt = evt_ts_start + (evt_basal_size/2);
        transient_histo_edges_msec = before_msec:transient_histo_bin_size_msec:after_msec;
    elseif ismember(Eventname,short_event)
        before_msec = -8000;
        after_msec = 8000;
        baseline_period_start_msec = -8000;
        baseline_period_stop_msec = -5000;
        transient_histo_edges_msec = before_msec:transient_histo_bin_size_msec:after_msec; 
    elseif ismember(Eventname,Locked_event)
        before_msec = -50000;
        after_msec = 50000;
        baseline_period_start_msec = -50000;
        baseline_period_stop_msec = -25000;
        transient_histo_edges_msec = before_msec:transient_histo_bin_size_msec:after_msec;
        transient_histo_edges_msec_transient = before_msec_transient:transient_histo_bin_size_msec:after_msec_transient;
    else    
        before_msec = -40000;
        after_msec = 100000;
        baseline_period_start_msec = -40000;
        baseline_period_stop_msec = -30000;
        transient_histo_edges_msec = before_msec:transient_histo_bin_size_msec:after_msec;
        transient_histo_edges_msec_transient = before_msec_transient:transient_histo_bin_size_msec:after_msec_transient;
    end

    %% rename variables to simplifiy code writing
    
    if ismember(Eventname,basal)
        evt_ts = center_basal_evt;
    else
        evt_ts = boris_data.events(i_event).start;
        evt_ts_transient = boris_data.events(i_event).start;
    end

    t = step1.dein_signals.time;
    t_transient = step1.dein_signals.time;
    dff = step1.dff;
    dff_transient = step1.dff;

     %% clean evt_ts
    idx = find(evt_ts<=t(1)+abs(before_msec/1000));
    evt_ts(idx)=[];
    idx = find(evt_ts>t(end)-(after_msec/1000));
    evt_ts(idx)=[];
 
    % clean evt_ts for specific transient time window
    if any(~ismember(Eventname,short_event)) && any(~ismember(Eventname,basal))
        idx_transient = find(evt_ts_transient<=t_transient(1)+abs(before_msec_transient/1000));
        evt_ts_transient(idx_transient)=[];
        idx_transient = find(evt_ts_transient>t_transient(end)-(after_msec_transient/1000));
        evt_ts_transient(idx_transient)=[];
    end
    
    %% estimate sampling frequency to transform time values into array indices values
    sfreq = 1/median(diff(t));
    sfreq_transient = 1/median(diff(t_transient));
    
    %% signal will be cut in time_windows surrounding each event
    % the limits of each time_window has been defined at the beginning of
    % the function in two variables which are : before_msec and after_msec
    before_idx = ceil((before_msec/1000)*sfreq);
    after_idx = ceil((after_msec/1000)*sfreq);
    size_idx = abs(before_idx) + abs(after_idx);
    
    x = linspace(before_msec,after_msec,size_idx);
    
    % total number of timestamps for this category of event
    n = length(evt_ts);

    % variable initialisation for in loop control
    dff_frag_matrix = nan(n,size_idx);i1 = nan(n,1);i2 = nan(n,1);center_idx = nan(n,1);
    t1 = nan(n,1);t2 = nan(n,1);
    
    selected_transients_idx={};
    selected_transients_ts={};

    % Do the same but for another time window (for transient analysis)
    if any(~ismember(Eventname,short_event)) && any(~ismember(Eventname,basal))

        before_idx_transient = ceil((before_msec_transient/1000)*sfreq_transient);
        after_idx_transient = ceil((after_msec_transient/1000)*sfreq_transient);
        size_idx_transient = abs(before_idx_transient) + abs(after_idx_transient);
        x_transient = linspace(before_msec_transient,after_msec_transient,size_idx_transient);
        n_transient = length(evt_ts_transient);
        dff_frag_matrix_transient = nan(n_transient,size_idx_transient);i1_t = nan(n_transient,1);i2_t = nan(n_transient,1);center_idx_transient = nan(n_transient,1);
        t1_t = nan(n_transient,1);t2_t = nan(n_transient,1);

        selected_transients_idx_bis= {};
        selected_transients_ts_bis= {};

        selected_transients_nb_bis= {};    
        selected_transients_nb_bis_before= {};
        selected_transients_nb_bis_after= {}; 

        selected_transients_width_bis= {}; 
        selected_transients_width_bis_before= {};
        selected_transients_width_bis_after= {};

        selected_transients_prominence_bis= {};
        selected_transients_prominence_bis_before= {};
        selected_transients_prominence_bis_after= {};

        selected_transients_peak_bis= {};
        selected_transients_peak_bis_before= {};
        selected_transients_peak_bis_after= {};

    end
    
    % calculating start and stop indices to cut a fragment of signal (dff)
    % around the event
    for j = 1:n
        
        %trial by trial, indices of start center and stop of the time
        %window surrounding each event
        center_idx(j) = find(t>evt_ts(j),1,'first');
        i1(j)= center_idx(j)+before_idx;i2(j)= center_idx(j)+after_idx-1;
        
        %fragment of the dff signal
        dff_frag_matrix(j,:) = dff(i1(j):i2(j));
        
        % timestamps of the surrounding window
        t1(j)=t(i1(j));t2(j)=t(i2(j));
        
        % transients contained in that window.
        j1 = find(step1.transients.time>t1(j));
        j2 = find(step1.transients.time<t2(j));
        idx = intersect(j1,j2);
        selected_transients_idx{j} = step1.transients.loc(idx);
        selected_transients_ts{j} = step1.transients.time(idx);
        
        % for debug only
        %selected_transients_ts{j} = sort(t(randi([i1(j) i2(j)],1,50)));
        %selected_transients_idx{j} = ones(1,50);
        
        %transients_frag_matrix(j,:) = histcounts(selected_transients_ts{j}-evt_ts(j),transient_histo_edges_msec/1000);

        if any(~ismember(Eventname,short_event)) && any(~ismember(Eventname,basal))

            %trial by trial, indices of start center and stop of the time
            %window surrounding each event
            center_idx_transient(j) = find(t_transient>evt_ts_transient(j),1,'first');
            i1_t(j)= center_idx_transient(j)+before_idx_transient ; i2_t(j)= center_idx_transient(j)+after_idx_transient-1;

            %fragment of the dff signal
            dff_frag_matrix_transient(j,:) = dff_transient(i1_t(j):i2_t(j));

            % timestamps of the surrounding window
            t1_t(j)=t_transient(i1_t(j));t2_t(j)=t_transient(i2_t(j));

            % transients contained in that window.
            j1_t = find(step1.transients.time>t1_t(j));
            j2_t = find(step1.transients.time<t2_t(j));
            j3_t = find(step1.transients.time>evt_ts_transient);
            j4_t = find(step1.transients.time<evt_ts_transient);

            idx_transient = intersect(j1_t,j2_t);
            idx_transient_before = intersect(j1_t,j4_t);
            idx_transient_after = intersect(j2_t,j3_t);

            % extract transients contained in all/before/after window event .

            selected_transients_idx_bis{j} = step1.transients.loc(idx_transient);
            selected_transients_ts_bis{j} = step1.transients.time(idx_transient);
        
            if verLessThan('matlab','9.9')
                selected_transients_nb_bis{j} = size(idx_transient,1);
                selected_transients_nb_bis_before{j} = size(idx_transient_before,1);
                selected_transients_nb_bis_after{j} = size(idx_transient_after,1);
            else
                selected_transients_nb_bis{j} = height(idx_transient);
                selected_transients_nb_bis_before{j} = height(idx_transient_before);
                selected_transients_nb_bis_after{j} = height(idx_transient_after);
            end
        
            selected_transients_width_bis{j} = step1.transients.width(idx_transient);
            selected_transients_width_bis_before{j} = step1.transients.width(idx_transient_before);
            selected_transients_width_bis_after{j} = step1.transients.width(idx_transient_after);

            selected_transients_prominence_bis{j} = step1.transients.prominence(idx_transient);
            selected_transients_prominence_bis_before{j} = step1.transients.prominence(idx_transient_before);
            selected_transients_prominence_bis_after{j} = step1.transients.prominence(idx_transient_after);

            selected_transients_peak_bis{j} = step1.transients.peak(idx_transient);
            selected_transients_peak_bis_before{j} = step1.transients.peak(idx_transient_before);
            selected_transients_peak_bis_after{j} = step1.transients.peak(idx_transient_after);

            % for debug only
            % selected_transients_ts{j} = sort(t(randi([i1(j) i2(j)],1,50)));
            % selected_transients_idx{j} = ones(1,50);

            %transients_frag_matrix_bis(j,:) = histcounts(selected_transients_ts_bis{j}-evt_ts_transient(j),transient_histo_edges_msec_transient/1000);
        
        end
    end

    %% we measure the zscore according to the baseline perdio defined by the user using
    %% baseline_period_start_msec and baseline_period_stop_msec
    
    if ismember(Eventname,basal)
    bsl_event_i1 = ceil((baseline_period_start_msec/1000)*sfreq) + abs(before_idx) + 1;
    bsl_event_i2 = ceil((baseline_period_stop_msec/1000)*sfreq) + abs(before_idx);
    else
    bsl_i1 = ceil((baseline_period_start_msec/1000)*sfreq) + abs(before_idx) + 1;
    bsl_i2 = ceil((baseline_period_stop_msec/1000)*sfreq) + abs(before_idx);
    %bsl_i1_transient = ceil((baseline_period_start_msec_transient/1000)*sfreq_transient) + abs(before_idx_transient) + 1;
    %bsl_i2_transient = ceil((baseline_period_stop_msec_transient/1000)*sfreq_transient) + abs(before_idx_transient);
    end
    
    %% Peri Event Time Analysis (PETA)

    if strcmp(Eventname,'Basal')
        event_bsl_mean = mean(dff_frag_matrix(:,bsl_event_i1:bsl_event_i2),2);
        event_bsl_std = std(dff_frag_matrix(:,bsl_event_i1:bsl_event_i2),0,2);
        continue
    end
    
    step2.(Eventname) = struct();
    step2.(Eventname).session_info = step1.session;

    if ismember(Eventname,eat_event)
        dff_PETA = boris_tools.matrix_statistics_zscored_event(dff_frag_matrix, bsl_i1, bsl_i2, event_bsl_mean, event_bsl_std);
        %transients_PETA = matrix_statistics(transients_frag_matrix_bis, bsl_i1_transient, bsl_i2_transient);

        step2.(Eventname).event_bsl_mean = event_bsl_mean;
        step2.(Eventname).event_bsl_std = event_bsl_std;

        step2.(Eventname).selected_transients_idx = selected_transients_idx;
        step2.(Eventname).selected_transients_ts = selected_transients_ts;
        step2.(Eventname).selected_transients_idx_bis = selected_transients_idx_bis;
        step2.(Eventname).selected_transients_ts_bis = selected_transients_ts_bis;
        step2.(Eventname).selected_transients_nb_bis = selected_transients_nb_bis;
        step2.(Eventname).selected_transients_nb_bis_before = selected_transients_nb_bis_before;
        step2.(Eventname).selected_transients_nb_bis_after = selected_transients_nb_bis_after;
        step2.(Eventname).selected_transients_prominence_bis = selected_transients_prominence_bis;
        step2.(Eventname).selected_transients_prominence_bis_before = selected_transients_prominence_bis_before;
        step2.(Eventname).selected_transients_prominence_bis_after = selected_transients_prominence_bis_after;
        step2.(Eventname).selected_transients_width_bis = selected_transients_width_bis;
        step2.(Eventname).selected_transients_width_bis_before = selected_transients_width_bis_before;
        step2.(Eventname).selected_transients_width_bis_after = selected_transients_width_bis_after;
        step2.(Eventname).selected_transients_peak_bis = selected_transients_peak_bis;
        step2.(Eventname).selected_transients_peak_bis_before = selected_transients_peak_bis_before;
        step2.(Eventname).selected_transients_peak_bis_after = selected_transients_peak_bis_after;
    
    end
   
    if any(ismember(Eventname,run_event)) || any(ismember(Eventname,Locked_event))
        dff_PETA = boris_tools.matrix_statistics_zscored_event(dff_frag_matrix, bsl_i1, bsl_i2, event_bsl_mean, event_bsl_std);
        %transients_PETA = matrix_statistics(transients_frag_matrix_bis, bsl_i1_transient, bsl_i2_transient);

        step2.(Eventname).event_bsl_mean = event_bsl_mean;
        step2.(Eventname).event_bsl_std = event_bsl_std;
        step2.(Eventname).selected_transients_idx = selected_transients_idx;
        step2.(Eventname).selected_transients_ts = selected_transients_ts;
        step2.(Eventname).selected_transients_idx_bis = selected_transients_idx_bis;
        step2.(Eventname).selected_transients_ts_bis = selected_transients_ts_bis;
        step2.(Eventname).selected_transients_nb_bis = selected_transients_nb_bis;
        step2.(Eventname).selected_transients_nb_bis_before = selected_transients_nb_bis_before;
        step2.(Eventname).selected_transients_nb_bis_after = selected_transients_nb_bis_after;
        step2.(Eventname).selected_transients_prominence_bis = selected_transients_prominence_bis;
        step2.(Eventname).selected_transients_prominence_bis_before = selected_transients_prominence_bis_before;
        step2.(Eventname).selected_transients_prominence_bis_after = selected_transients_prominence_bis_after;
        step2.(Eventname).selected_transients_width_bis = selected_transients_width_bis;
        step2.(Eventname).selected_transients_width_bis_before = selected_transients_width_bis_before;
        step2.(Eventname).selected_transients_width_bis_after = selected_transients_width_bis_after;
        step2.(Eventname).selected_transients_peak_bis = selected_transients_peak_bis;
        step2.(Eventname).selected_transients_peak_bis_before = selected_transients_peak_bis_before;
        step2.(Eventname).selected_transients_peak_bis_after = selected_transients_peak_bis_after;
    
    end

    if ismember(Eventname,short_event)
        dff_PETA = boris_tools.matrix_statistics(dff_frag_matrix, bsl_i1, bsl_i2);
        %step2.(Eventname).event_bsl_mean = event_bsl_mean;
        %step2.(Eventname).event_bsl_std = event_bsl_std;
    end

    step2.(Eventname).evt_ts = evt_ts;
    step2.(Eventname).i1 = i1;
    step2.(Eventname).i2 = i2;
    step2.(Eventname).center_idx = center_idx;
    step2.(Eventname).t1 = t1;
    step2.(Eventname).t2 = t2;
    step2.(Eventname).D = dff_frag_matrix;
    step2.(Eventname).before_msec = before_msec;
    step2.(Eventname).after_msec  = after_msec;
    step2.(Eventname).baseline_period_start_msec = baseline_period_start_msec;
    step2.(Eventname).baseline_period_stop_msec = baseline_period_stop_msec;
    step2.(Eventname).bsl_i1 = bsl_i1;
    step2.(Eventname).bsl_i2 = bsl_i2;
    step2.(Eventname).x = x;
    step2.(Eventname).dff_PETA = dff_PETA;
    
    %step2.(Eventname).transients_PETA = transients_PETA;
    %step2.(Eventname).transients_PETA.edges_msec_transient = transient_histo_edges_msec_transient;
    %step2.(Eventname).transients_PETA.bin_size_msec_transient = transient_histo_bin_size_msec_transient;
    %%plot_dff_fragments(step1, step2(i_event), Eventname);
    %%plot_transients_fragments(step1, step2(i_event), Eventname);
   
end

 data_tools.save_step2(step1,step2);
