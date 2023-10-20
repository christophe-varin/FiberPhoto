function [sig_tag,p_val,observeddifference] = permTest_2sample(data1,data2,nb_perms,alpha_sig,min_duration)

exact = false;

allobservations = vertcat(data1,data2);
observeddifference = mean(data1,1) - mean(data2,1);
s1_n = size(data1,1);
all_n = size(allobservations,1);
win_size = size(data1,2);

w = warning('off', 'MATLAB:nchoosek:LargeCoefficient');
if  nb_perms > nchoosek(all_n,s1_n)
	exact = true;
    allcombinations = nchoosek(1:all_n,s1_n);
    disp(['Number of permutations (',num2str(nb_perms),') is higher than the number of possible combinations (',num2str(nchoosek(all_n,s1_n)),') ',...
             'Running exact test (minimum p = ',num2str(1/(nchoosek(all_n,s1_n)+1)),')']);
    nb_perms = size(allcombinations,1);
end

% running test
randomdifferences = zeros(win_size,nb_perms);

for nn=1:1:nb_perms
    % selecting next combination or random permutation
    if exact; permutation = [allcombinations(nn,:),setdiff(1:all_n,allcombinations(nn,:))];
    else; permutation = randperm(all_n); end
    % dividing into two samples
    randomSample1 = allobservations(permutation(1:s1_n),:);
    randomSample2 = allobservations(permutation(s1_n+1:all_n),:);
    % random differences between the two samples
    randomdifferences(:,nn) = mean(randomSample1,1)-mean(randomSample2,1);
end

% getting probability of finding observed difference from random permutations
p_val = zeros(1,win_size);
for tt=1:1:win_size
    p_val(tt) = (sum(abs(randomdifferences(tt,:))>abs(observeddifference(tt)))+1)/(nb_perms+1);
end
sig_tag = double(p_val<=alpha_sig);
sig_bouts = find(diff(sig_tag)==1)+1;
for ii=1:1:length(sig_bouts)
    duration = find(~sig_tag(sig_bouts(ii):end),1,'first')-1;
    if duration<=min_duration
        sig_tag(sig_bouts(ii):(sig_bouts(ii)+duration)) = false;
    end
end

end