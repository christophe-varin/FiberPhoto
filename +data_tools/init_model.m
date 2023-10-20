function s_model = init_model(analysis_folder)
%% CREATION OF THE STRUCTURE WHO COLLECT EVERYTHING

s_model = struct(); 

% ANALYSIS PARAMETERS ON THE OUTPUTS (main_structure : s)
% step1
s_model.figure.savepng = 1;
s_model.figure.savefig = 1;
s_model.figure.closefig = 1;

s_model.debug.mode = 0;
s_model.debug.folder = [analysis_folder filesep 'debug_figures'];
s_model.debug.savepng = s_model.figure.savepng;
s_model.debug.savefig = s_model.figure.savefig;
s_model.debug.closefig = s_model.figure.closefig;

% step2
s_model.psth.before_msec = -100000;
s_model.psth.after_msec  = 60000;
s_model.psth.baseline_period_start_msec = -70000;
s_model.psth.baseline_period_stop_msec = -65000;
s_model.psth.transient_histo_bin_size_msec = 250;

end
