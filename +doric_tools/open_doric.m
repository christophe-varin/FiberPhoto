function [raw_signals, deinterleaved_signals] = open_doric(filepath,s)

%% argument to enable the plot of debug figures
debug = s.debug;

%% PARAMETERS START
%remove artifacts from chuncks
artifact_th_high = 10; % MAD
artifact_th_low = 1; % MAD
%PARAMETERS STOP

%% LOAD DORIC DATA
[header, data] = load_doric_csv(filepath);
raw_signals = doric_csv_to_data_structure(header,data);
clear data; %data variable is huge, it needs to be cleaned has soon has possible

%% REMOVE MISSING VALUES
raw_signals = remove_missing_values(raw_signals);

%% MEASURE SAMPLING FREQUENCY
raw_signals = detect_sampling_frequency(raw_signals);

%% DETECT LED 405nm and 470nm ACTIVITIES
raw_signals = get_even_pulses(raw_signals); %detect LED 405 and 470 on/off
%,TEST PLOTS
plot_pulses_detection(raw_signals, debug);
plot_pulses_durations(raw_signals, debug);

if length(raw_signals.digitalOut3)>1
    plot_dio_signal(raw_signals.time, raw_signals.digitalOut3, raw_signals.digSig3_on_idx, raw_signals.digSig3_off_idx, 'dio3', debug)
end

if length(raw_signals.digitalOut4)>1
    plot_dio_signal(raw_signals.time, raw_signals.digitalOut4, raw_signals.digSig4_on_idx, raw_signals.digSig4_off_idx, 'dio4', debug)
end

%% DEINTERLEAVED
% we truncate AnlaogIn #1 sig to extract iso and physio signals based on
% median duration
[t_chunks, iso_chunks, physio_chunks] = raw_deinterleaved_signals(raw_signals);% using LED on/off info
% TEST PLOTS
plot_raw_deinterleaved_signals(t_chunks, iso_chunks, physio_chunks, debug);

%% REMOVE EXCITATION ARTIFACTS
% because LED are not stable
% those artifacts always happend at the beginning of each chunk
% this is a method to remove them
[iso_artifact_idx] = find_artifact_idx(iso_chunks, artifact_th_high, artifact_th_low);
iso_artifact_id = ceil(prctile(iso_artifact_idx, 95));
[physio_artifact_idx] = find_artifact_idx(physio_chunks, artifact_th_high, artifact_th_low);
physio_artifact_id = ceil(prctile(physio_artifact_idx, 95));
% TEST PLOTS
plot_artifact_idx(iso_chunks, iso_artifact_idx, 'iso', debug);
plot_artifact_idx(physio_chunks, physio_artifact_idx, 'physio', debug);
artifact_id = max([iso_artifact_id, physio_artifact_id]);
[t_chunks, iso_chunks, physio_chunks] = clean_deinterleaved_signals(t_chunks, iso_chunks, physio_chunks, artifact_id);
[t, iso, physio] = avg_deinterleaved_signals(t_chunks, iso_chunks, physio_chunks);

%% UPDATE STRUCTURE BEFORE RETURNING IT
deinterleaved_signals.time = t;
deinterleaved_signals.iso = iso;
deinterleaved_signals.physio = physio;

end

%% SUBFUNCTIONS

function [header, data] = load_doric_csv(filepath)
% This function take a path to a doric csv file and return the headers
% of the columns in header_raw as well as all the data
n_line_header = 2; % In 2021 Doric csv file has two lines of header
fp = fopen(filepath,'r'); % Open the csv file in read mode 'r'
for i=1:n_line_header, tline = fgetl(fp); end  %owerwrite first line, only second line has an inerrest
% Upon closer inspection, it seems that only the second line has interesting info
% We get the column names, removing extra spaces because it is probably more convenient
tline = strrep(tline,' ', ''); %remove spaces
tline = strrep(tline,'--', '/'); % Sometimes this wonderful software replaces '/' with '--' so we try to compensate
header = split(tline,','); % split by coma (csv file) and return the header of each column in an cell array call header
data = dlmread(filepath,',',2,0); % read everything from the 3 line (skip 2) without skipiing columns (0) and place it in a 2D matrix called data
end

function raw_signals = doric_csv_to_data_structure(h,d)
%Based on the Header of the csv file, disscoiate the data into separate
%variables, the advantage is that if the column order changes you can
%still collect your data
raw_signals.time = d(:,find(ismember(h,'Time(s)')));
raw_signals.digitalOut1 = d(:,find(ismember(h,'DI/O-1')));
raw_signals.digitalOut2 = d(:,find(ismember(h,'DI/O-2')));
raw_signals.digitalOut3 = d(:,find(ismember(h,'DI/O-3')));
raw_signals.digitalOut4 = d(:,find(ismember(h,'DI/O-4')));
raw_signals.analogIn1 = d(:,find(ismember(h,'AIn-1')));
end

function raw_signals = remove_missing_values(raw_signals)
%Sometimes Doric Systems could not save the data and there is a zero in
%the raw_signals.analogIn1, so we will remove this lines
zero_idx = find(raw_signals.analogIn1==0);
s = max(size(zero_idx));
n = max(size(raw_signals.analogIn1));
fprintf('%d (%2.2f%%) missing values have been detected\n',s, (s/n)*100.0 );
raw_signals.time(zero_idx)=[];
raw_signals.analogIn1(zero_idx)=[];
raw_signals.digitalOut1(zero_idx)=[];
raw_signals.digitalOut2(zero_idx)=[];
m = length(raw_signals.digitalOut3);
if m>1
    raw_signals.digitalOut3(zero_idx)=[];
end
m = length(raw_signals.digitalOut4);
if m>1
    raw_signals.digitalOut4(zero_idx)=[];
end
end

function raw_signals = detect_sampling_frequency(raw_signals)
dt = diff(raw_signals.time);
if min(dt)==0
    print('error in data file, timestamps are duplicated !!!')
end
raw_signals.sfreq = 1.0/median(dt);
fprintf('Doric file was recorded at %2.2fHz\n',raw_signals.sfreq);

end

function [idx_on,idx_off] = detect_digital_pulses(sig)
% In doric csv file, there columns storing the value of the digital I/O,
% these vales are equal to 0 or 1, using the derivative we can easly find
% transition from 0 to 1 or from 1 to 0
d = diff(sig);
idx_on = find(d==1);
idx_off = find(d==-1);
end

function raw_signals = get_even_pulses(raw_signals)

%% First we extract the signal controling the 405nm LED (dio1) and the 470nm LED (dio2)
[digSig1_on_idx,digSig1_off_idx] = detect_digital_pulses(raw_signals.digitalOut1);
[digSig2_on_idx,digSig2_off_idx] = detect_digital_pulses(raw_signals.digitalOut2);

%% Ensure that vector have same size (same number of LED completed Pulses Gcamp and ISO)
%if the last iso (405 nm) pulse (digOut1), pulse has been cut in the middle, we remove the
%last on_idx value
if size(digSig1_off_idx,1) < size(digSig1_on_idx,1)
    digSig1_on_idx(end)=[];
end
%if the last signal (470 nm) pulse (digOut2), pulse has been cut in the middle, we remove the
%last on_idx value
if size(digSig2_off_idx,1) < size(digSig2_on_idx,1)
    digSig2_on_idx(end)=[];
end

%if the last pulse is an iso pulse we remove it because we start by an
%iso pulse.
if size(digSig2_on_idx,1) < size(digSig1_on_idx,1)
    digSig1_on_idx(end)=[];
    digSig1_off_idx(end)=[];
end
raw_signals.digSig1_on_idx = digSig1_on_idx;
raw_signals.digSig1_off_idx = digSig1_off_idx;
raw_signals.digSig2_on_idx = digSig2_on_idx;
raw_signals.digSig2_off_idx = digSig2_off_idx;

%% Then we look at dio3 and dio4
m = length(raw_signals.digitalOut3);
if m>1
    [digSig3_on_idx,digSig3_off_idx] = detect_digital_pulses(raw_signals.digitalOut3);
    if size(digSig3_off_idx,1) < size(digSig3_on_idx,1)
        digSig3_on_idx(end)=[];
    end
    raw_signals.digSig3_on_idx = digSig3_on_idx;
    raw_signals.digSig3_off_idx = digSig3_off_idx;   
end

m = length(raw_signals.digitalOut4);
if m>1
    [digSig4_on_idx,digSig4_off_idx] = detect_digital_pulses(raw_signals.digitalOut4);
    if size(digSig4_off_idx,1) < size(digSig4_on_idx,1)
        digSig4_on_idx(end)=[];
    end
    raw_signals.digSig4_on_idx = digSig4_on_idx;
    raw_signals.digSig4_off_idx = digSig4_off_idx;   
end

end


function trunc = extract_signal(idx_pulse_on, idx_pulse_off, sig)
% Doric system record a continous AnalogIn1 which contains interleaved
% physio and iso signals. Using LED on and off times (indices here) whe
% can truncate AnalogIn1 in small section corresponding to one led
% only.
min_pulse_width = min(idx_pulse_off-idx_pulse_on);
n_Samples = size(idx_pulse_on,1);
trunc = nan(n_Samples,min_pulse_width);
for i=1:n_Samples
    j = idx_pulse_on(i);
    k = j + min_pulse_width -1;
    trunc(i,:) = sig([j:k]);
end
end

function [t_chunks, sig1_chunks, sig2_chunks] = raw_deinterleaved_signals(raw_signals)
%based on the LED states (O or 1) for 405 nm and 470 nm we truncate
%AnalogIn #1 and time vectors
[t,a,i1_on,i1_off,i2_on,i2_off] = expose_raw_signal_values(raw_signals);
t_chunks = extract_signal(i1_on, i1_off, t);
sig1_chunks = extract_signal(i1_on, i1_off, a);
sig2_chunks = extract_signal(i2_on, i2_off, a);
end

function [trim_thresholds] = find_artifact_idx(sig, high_th, low_th)
n_Samples = size(sig,2);
abs_diff_sig = abs(diff(sig,1,2));
trim_thresholds = nan(n_Samples,1);
for i=1:n_Samples
    mad_ = mad(abs_diff_sig(i,floor(n_Samples/4):end));
    idx1 = find(abs_diff_sig(i,:)>(high_th*mad_),1,'last');
    idx2 = find(abs_diff_sig(i,idx1:end)<(low_th*mad_),1,'first');
    if ~isempty(idx2) && ~isempty(idx1)
        trim_thresholds(i) = idx2 + idx1;
    else
        trim_thresholds(i) = size(sig,1);
    end
end
end

function [t_chunks, iso_chunks, physio_chunks] = clean_deinterleaved_signals(t_chunks, iso_chunks, physio_chunks, trim_id)
t_chunks = t_chunks(:,trim_id:end);
iso_chunks = iso_chunks(:,trim_id:end);
physio_chunks = physio_chunks(:,trim_id:end);
end

function [t, iso, physio] = avg_deinterleaved_signals(t_chunks, iso_chunks, physio_chunks)
t = mean(t_chunks,2);
iso = mean(iso_chunks,2);
physio = mean(physio_chunks,2);
end

function [t,a,i1_on,i1_off,i2_on,i2_off] = expose_raw_signal_values(raw_signals)
% a simple function to acess the element of the raw-signals structure with
% shorter variable names
t = raw_signals.time;
a = raw_signals.analogIn1;
i1_on = raw_signals.digSig1_on_idx;
i1_off = raw_signals.digSig1_off_idx;
i2_on = raw_signals.digSig2_on_idx;
i2_off = raw_signals.digSig2_off_idx;
end


%% DEBUG PLOT FUNCTIONS

function plot_pulses_detection(raw_signals, debug)
if debug.mode
    [t,a,i1_on,i1_off,i2_on,i2_off] = expose_raw_signal_values(raw_signals);
    fig=figure();
    hold on
    plot(t,a,'k');
    plot(t(i1_on),a(i1_on),'m^');
    plot(t(i1_off),a(i1_on),'mv');
    plot(t(i2_on),a(i1_on),'b^');
    plot(t(i2_off),a(i1_on),'bv');    
    smart_save_figures(fig, debug, 'pulses_detection');        
end
end

function plot_pulses_durations(raw_signals, debug)
if debug.mode
    [t,a,i1_on,i1_off,i2_on,i2_off] = expose_raw_signal_values(raw_signals);
    fig=figure();
    subplot(1,2,1)
    title('iso pulses duration')
    hold on
    histogram(i1_off-i1_on,'FaceColor','m')
    pulse1_width = median(i1_off-i1_on);
    subplot(1,2,2)
    title('physio pulses duration')
    hold on
    histogram(i2_off-i2_on,'FaceColor','b')
    pulse2_width = median(i2_off-i2_on);
    smart_save_figures(fig, debug, 'durations')       
end
end

function plot_raw_deinterleaved_signals(t_tr, iso_tr, physio_tr, debug)
if debug.mode
    fig=figure();
    subplot(1,2,1)
    title('iso chuncks')
    hold on
    plot(iso_tr','m');
    subplot(1,2,2)
    title('physio chuncks')
    hold on
    plot(physio_tr','b');
    smart_save_figures(fig, debug, 'deinterleaved_chunks')  
end
end

function plot_artifact_idx(chuncks, trim_idx, sig_str, debug)
if debug.mode
    abs_diff_chunk = abs(diff(chuncks,1,2));
    fig=figure();
    title(sprintf('trim %s',sig_str))
    hold on
    plot(abs_diff_chunk','m');
    s = size(trim_idx);
    s = s(1);
    for i=1:s
        plot([trim_idx(i) trim_idx(i)],[0 1],'color',[0.5 0.5 0.5]);
    end
    plot([median(trim_idx) median(trim_idx)],[0 1],'color',[1 0 0], 'linewidth',2);  
    smart_save_figures(fig, debug, [sig_str '_artifact_idx'])  
end
end



function plot_dio_signal(t,sig, i_on, i_off, title_, debug)
if debug.mode   
    fig=figure();
    title(title_)
    hold on
    plot(t,sig,'k');
    plot(t(i_on),sig(i_on),'g^');
    plot(t(i_off),sig(i_off),'gv'); 
    ylim([-1 2]);
    smart_save_figures(fig, debug, title_);        
end
end






