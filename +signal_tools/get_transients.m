function transients = get_transients(t, dff, debug)

lowPassTh_Hz= 0.1;
highPassTh_Hz= 2;
filterType = 'bandpass';

fc = [lowPassTh_Hz highPassTh_Hz];
fs = 1/median(diff(t));
[b,c] = butter(4,fc/(fs/2));
filtered_sig = filtfilt(b, c, dff);

two_MAD_th = median(filtered_sig) + (2*mad(filtered_sig));
one_MAD_th = median(filtered_sig) + mad(filtered_sig);

MinPeakGap_s = 0.1;
[pks,locs,w,p] = findpeaks(filtered_sig, 'MinPeakHeight',two_MAD_th, 'MinPeakDistance', floor(MinPeakGap_s * fs), 'MinPeakProminence', mad(filtered_sig));

transients.time = t(locs);
transients.loc = locs;
transients.peak = pks;
transients.width = w;
transients.prominence = p;
transients.MinPeakHeight = two_MAD_th;
transients.MinPeakDistance = floor(MinPeakGap_s * fs);
transients.MinPeakProminence = mad(filtered_sig);
transients.filtered_sig = filtered_sig;
transients.filtered_sig_median = median(filtered_sig);
transients.oneMAD = mad(filtered_sig);

if debug.mode
    n = size(locs,1);
    fig=figure();
    subplot(2,1,1)
    plot_tools.plot_transients(transients,t,filtered_sig,'dff filtered',1)
    subplot(2,1,2)
    plot_tools.plot_transients(transients,t,dff,'dff',0)
    plot_tools.smart_save_figures(fig, debug, 'transients_detection')
end

end




 















