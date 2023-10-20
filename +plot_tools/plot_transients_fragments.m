function fig = plot_transients_fragments(step1, step2, Eventname)

i1 = step2.(Eventname).i1;
i2 = step2.(Eventname).i2;
D = step2.(Eventname).D;
x = step2.(Eventname).x;
zscored = step2.(Eventname).transients_PETA.zscored_matrix;
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
fig=figure('Name',Eventname)
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
for j=1:n
    x = step2.(Eventname).selected_transients_ts{j};
    idx =  step2.(Eventname).selected_transients_idx{j};
    n2 = length(x);
    max_ = max(dff);
    for k=1:n2
        plot([x(k) x(k)],[dff(idx(k)) max_],'color', cmap(j,:));
        plot(x(k), max_, 'Marker', '*','color', cmap(j,:));
    end
end
xlabel('Time(s)')
ylabel('DFF(%)')


subplot(3,2,3)
title('Transients around event');
hold on
evt_ts = step2.(Eventname).evt_ts;
% total number of timestamps for this category of event
n = length(evt_ts);
for j=1:n
    %fprintf('\ncenter = %f',step2.center_idx(j))
    plot([step2.(Eventname).before_msec/1000 step2.(Eventname).after_msec/1000],[j j],'color', cmap(j,:),'LineWidth',1,'LineStyle',':');
    if ~isempty(step2.(Eventname).selected_transients_ts{j})
        x = step2.(Eventname).selected_transients_ts{j};
        %fprintf('selected_transients = %f',x)
        x = x-step2.(Eventname).evt_ts(j);
        plot(x,ones(length(x))*j,'Marker','o','MarkerEdgeColor','none','MarkerFaceColor','k','LineStyle','none');       
    end
end
plot([0 0],[-1 n+1],'r')
ylim([-1 n+1]);
xlim([step2.(Eventname).before_msec/1000 step2.(Eventname).after_msec/1000]);
xlabel('Time(s)')
ylabel('Frequency(Hz)')



bin_size_msec = step2.(Eventname).transients_PETA.bin_size_msec
edges_msec = step2.(Eventname).transients_PETA.edges_msec;
edges_sec = edges_msec./1000;
n_edges = size(edges_sec,2);


subplot(3,2,5)
title('Transient Frequency around event');
hold on
x = (edges_msec(1:end-1)+bin_size_msec/2)/1000;
mean_ = step2.(Eventname).transients_PETA.matrix_mean;
mean_Hz = mean_/(bin_size_msec/1000);
std_ = step2.(Eventname).transients_PETA.matrix_std;
std_Hz = std_/(bin_size_msec/1000);
plot(x,mean_Hz,'k');
plot(x,mean_Hz+std_Hz, 'k:');
plot(x,mean_Hz-std_Hz, 'k:');
x_ = [x flip(x)];
y_ = [mean_Hz+std_Hz , flip(mean_Hz-std_Hz)];
patch(x_, y_, [0 0 0],'FaceAlpha',.1, 'Edgecolor', 'none');
plot([0 0],[min(y_) max(y_)],'r')
xlabel('Time(s)')
ylabel('Frequency(Hz)')




subplot(3,2,6)
title('Transient zscored around event');
hold on
x = (edges_msec(1:end-1)+bin_size_msec/2)/1000;
mean_ = step2.(Eventname).transients_PETA.z_mean;
std_ =  step2.(Eventname).transients_PETA.z_std;
plot(x,mean_,'k');
plot(x,mean_+std_, 'k:');
plot(x,mean_-std_, 'k:');
x_ = [x flip(x)];
y_ = [mean_+std_ , flip(mean_-std_)];
patch(x_, y_, [0 0 0],'FaceAlpha',.1, 'Edgecolor', 'none');
plot([0 0],[min(y_) max(y_)],'r')


x1 = baseline_period_start_msec/1000;
w1 = baseline_period_stop_msec/1000 - x1;
y1= nanmin(nanmin(zscored));
h1= nanmax(nanmax(zscored))-y1;
if ~isinf(x1) && ~isinf(y1) && ~isinf(w1) && ~isinf(h1)
rectangle('Position',[x1 y1 w1 h1], 'EdgeColor', 'none', 'FaceColor', [0.5 0.5 0.5 0.5]);
end
xlabel('Time(s)');
ylabel('zscored Frequency');




disp('h')





end