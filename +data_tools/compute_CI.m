function [CI,sig_from_0] = compute_CI(data,nb_bootstrap,alpha_sig,consecutive_points)

%INPUTS: data, data matrix dim trials x time
%        num_bouts, number of bootstrap
%        sig_alpha, significance threshold for CI
%        min_duration, consecutive bins required to register as significantly different to zero

[nb_trials,nb_time] = size(data);

if nb_trials>2
    data_boots = zeros(nb_bootstrap, nb_time);
    CI = zeros(2,nb_time);
    for b=1:1:nb_bootstrap
        trial_array = ceil((nb_trials).*rand(1,nb_trials));
        data_boots(b,:) = mean(data(trial_array,:));
    end
    %calculate bootstrap CI
    data_boots = sort(data_boots,1);
    lower_conf = ceil(nb_bootstrap*(alpha_sig/2))+1;
    upper_conf = floor(nb_bootstrap*(1-alpha_sig/2));
    CI(1,:) = data_boots(lower_conf,:);
    CI(2,:) = data_boots(upper_conf,:);
    
    %CI expansion sqrt(N/(N+1))
    CI(1,:) = (CI(1,:)-mean(data,1,'omitnan'))*sqrt(nb_trials/(nb_trials-1))+mean(data,1,'omitnan');
    CI(2,:) = (CI(2,:)-mean(data,1,'omitnan'))*sqrt(nb_trials/(nb_trials-1))+mean(data,1,'omitnan');
    
    %define significant bins
    non_zero_cross = CI(1,:)>0 | CI(2,:)<0;
    %clean if shorter than min_duration bins
    sig_bouts = find(diff(non_zero_cross)==1)+1;
    for ii=1:1:length(sig_bouts)
        duration = find(~non_zero_cross(sig_bouts(ii):end),1,'first')-1;
        if duration<=consecutive_points
            non_zero_cross(sig_bouts(ii):(sig_bouts(ii)+duration)) = false;
        end
    end
    sig_from_0 = non_zero_cross;
else
    disp('2 trials or less - CIs not computed');
    CI = NaN;
    sig_from_0 = NaN;
end

