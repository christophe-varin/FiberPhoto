function [t_tr, iso_tr, physio_tr] = left_trim_signals(t, iso, physio, duration_sec)
    sfreq = 1/median(diff(t));
    trim_size = floor(duration_sec * sfreq);
    t_tr = t(trim_size:end);
    iso_tr = iso(trim_size:end);
    physio_tr = physio(trim_size:end); 
end