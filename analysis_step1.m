function step1 = analysis_step1(f, step1)

%% LOAD DORIC DATA
[step1.raw_signals, step1.dein_signals] = doric_tools.open_doric(f, step1);
plot_tools.photo_plots(step1, 'deinterleaved signals');

%% LEFT TRIM TO REMOVE STRONG PHOTOBLEATCHING AT THE BEGINNING
step1.left_trim_dur_sec = 15;
[step1.dein_signals.time, step1.dein_signals.iso, step1.dein_signals.physio] = signal_tools.left_trim_signals(step1.dein_signals.time, step1.dein_signals.iso, step1.dein_signals.physio, step1.left_trim_dur_sec);

%% FIT ISO
step1.dein_signals.fit_iso = signal_tools.fit_iso(step1.dein_signals.iso, step1.dein_signals.physio);
plot_tools.photo_plots(step1, 'fit iso');

%% PROCESS DFF
step1.dff = signal_tools.calculate_dff(step1.dein_signals.time, step1.dein_signals.fit_iso, step1.dein_signals.physio)*100.0;
%photo_plots(data, 'dff_debug');
plot_tools.photo_plots(step1, 'dff');

%% EXTRACT TRANSIENTS
step1.transients = signal_tools.get_transients(step1.dein_signals.time, step1.dff, step1.debug);
plot_tools.photo_plots(step1, 'transients');
%% save
data_tools.save_step1(step1);% remove the raw_signals from the s structure and save it