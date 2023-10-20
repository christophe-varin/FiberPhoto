function sig_diff = pairwise_CI(data1,data2,num_boots,sig_alpha,min_duration)

[trials_nb_1,time_nb] = size(data1);
[trials_nb_2,~] = size(data2);

observed_difference = mean(data1,1)-mean(data2,1);

if trials_nb_1>2 && trials_nb_2>2
    
    data_boots = zeros(num_boots, time_nb);
    CI = zeros(2,time_nb);
    for b=1:1:num_boots
        trial_array1 = ceil((trials_nb_1).*rand(1,trials_nb_1));
        trial_array2 = ceil((trials_nb_2).*rand(1,trials_nb_2));
        data_boots(b,:) = mean(data1(trial_array1,:)) - mean(data2(trial_array2,:));
    end
    
    %calculate bootstrap CI
    data_boots = sort(data_boots,1);
    lower_conf = ceil(num_boots*(sig_alpha/2))+1;
    upper_conf = floor(num_boots*(1-sig_alpha/2));
    CI(1,:) = data_boots(lower_conf,:);
    CI(2,:) = data_boots(upper_conf,:);
    
    %CI expansion sqrt(N/(N+1))
    trials_nb = min(trials_nb_1,trials_nb_2);
    CI(1,:) = (CI(1,:)-observed_difference)*sqrt(trials_nb/(trials_nb-1))+observed_difference;
    CI(2,:) = (CI(2,:)-observed_difference)*sqrt(trials_nb/(trials_nb-1))+observed_difference;
    non_zero_cross = CI(1,:)>0 | CI(2,:)<0;
    %clean if shorter than min_duration bins
    sig_bouts = find(diff(non_zero_cross)==1)+1;
    for ii=1:1:length(sig_bouts)
        duration = find(~non_zero_cross(sig_bouts(ii):end),1,'first')-1;
        if duration<=min_duration
            non_zero_cross(sig_bouts(ii):(sig_bouts(ii)+duration)) = false;
        end
    end
    sig_diff = non_zero_cross;

else
    disp('No more than 3 trials - CIs not computed');
    sig_diff = NaN;
end