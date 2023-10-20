function fig = plot_dff_fragments(step1, step2, Eventname)

    i1 = step2.(Eventname).i1;
    i2 = step2.(Eventname).i2;
    D = step2.(Eventname).D;
    x = step2.(Eventname).x;
    mean_frag_raw = step2.(Eventname).dff_PETA.matrix_mean;
    std_frag_raw = step2.(Eventname).dff_PETA.matrix_std;
    mean_frag_zscore = step2.(Eventname).dff_PETA.z_mean;
    std_frag_zscore = step2.(Eventname).dff_PETA.z_std;
    zscored = step2.(Eventname).dff_PETA.zscored_matrix;
    baseline_period_start_msec = step2.(Eventname).baseline_period_start_msec;
    baseline_period_stop_msec = step2.(Eventname).baseline_period_stop_msec;
    evt_ts = step2.(Eventname).evt_ts;
    
    
    %% rename variables to simplifiy code writing
    t = step1.dein_signals.time;
    dff = step1.dff;
    % total number of timestamps for this category of event
    n = length(evt_ts);

    %% We plot the resutls
    Event = string(Eventname)
    fig = figure('Name',Event)
    cmap = colormap(hsv(n));
    
    subplot(3,2,[1 2])
    hold on
    title('dff (entire session)');
    plot(step1.dein_signals.time,step1.dff, 'color', [125, 125, 125]/255);
    for j=1:n
        plot([evt_ts(j) evt_ts(j)],[min(dff) max(dff)],'color', cmap(j,:));
    end
    for j=1:n
        plot(t(i1(j):i2(j)),D(j,:),'color',  cmap(j,:));
    end
    xlabel('Time(s)')
    ylabel('DFF(%)')
    
    
    subplot(3,2,3)
    hold on
    title('DFF around event');
    for j=1:n
        plot(x,D(j,:),'color', cmap(j,:));
    end
    xlabel('Time(s)')
    ylabel('DFF(%)')
    
    subplot(3,2,5)
    hold on
    title('Mean DFF around event');
    plot(x,mean_frag_raw,'k');
    plot(x,mean_frag_raw+std_frag_raw, 'k:');
    plot(x,mean_frag_raw-std_frag_raw, 'k:');
    x_ = [x flip(x)];
    y_ = [mean_frag_raw+std_frag_raw , flip(mean_frag_raw-std_frag_raw)];
    patch(x_, y_, [0 0 0],'FaceAlpha',.1, 'Edgecolor', 'none');
    xlabel('Time(s)')
    ylabel('DFF(%)')
    
    
    subplot(3,2,4)
    hold on
    title('zscored DFF around event');
    
    for j=1:n
        plot(x,zscored(j,:),'color', cmap(j,:));
    end
    
    %represent the baseline perdio by a black rectangle
    x1 = baseline_period_start_msec;
    w1 = baseline_period_stop_msec - x1;
    y1= min(zscored',[],'all');
    h1= max(zscored',[],'all') - y1;
    rectangle('Position',[x1 y1 w1 h1], 'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5 0.5]);
    xlabel('Time(s)');
    ylabel('zscored DFF(%)');
    
    
    subplot(3,2,6)
    hold on
    title('Mean zscored DFF around event');
    plot(x,mean_frag_zscore,'k');
    plot(x,mean_frag_zscore+std_frag_zscore, 'k:');
    plot(x,mean_frag_zscore-std_frag_zscore, 'k:');
    x_ = [x flip(x)];
    y_ = [mean_frag_zscore+std_frag_zscore , flip(mean_frag_zscore-std_frag_zscore)];
    patch(x_, y_, [0 0 0],'FaceAlpha',.1, 'Edgecolor', 'none');
    xlabel('Time(s)')
    ylabel('zscored DFF(%)')
    
    
end

