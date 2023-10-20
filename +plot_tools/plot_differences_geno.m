function plot_differences_geno(Dataset,CI_events,Sig_events,ee,plot_Xlimits,AUC_limits)

geno_names = {'D1','D2'};
colors_geno = [1 0 0; 0 0 1]; %red for D1 / blue for D2
events_names = {'door_eat','go_eat','eat','door_run','go_run','w_on','w_on2','w_off','w_blk','plt1'};
events_display = {'Feeding room access','Go eat','Start feeding','Running room access','Go run','First run','Start running','Stop running','Locked wheel','First pellet consumption'};

figure('Name',events_display{ee});
nlin = 2; ncol = 4;
subplot(nlin,ncol,1:ncol)
data1 = Dataset.events.data{ee,1}; data1t = Dataset.events.transient{ee,1};
data2 = Dataset.events.data{ee,2}; data2t = Dataset.events.transient{ee,2};
lim_up = ceil(max(max(CI_events{ee,1}(:)),max(CI_events{ee,2}(:))))+0.5;
%significant difference using permutation method -> more conservative than sig_bCI
sig_perm = data_tools.permTest_2sample(data1,data2,nb_bootstrap,alpha_sig,consecutive_points);
%significant difference using significance of bootstrap difference -> less conservative than sig_perm
sig_bCI = data_tools.pairwise_CI(data1,data2,nb_bootstrap,alpha_sig,consecutive_points);    
plot(Dataset.events.time{ee,1},zeros(size(Dataset.events.time{ee,1})),':k',[0 0],[-2 lim_up],':k'); hold on
x_ = [Dataset.events.time{ee,1} flip(Dataset.events.time{ee,1})];
y_ = [CI_events{ee,1}(2,:),flip(CI_events{ee,1}(3,:))];
patch(x_, y_, colors_geno(1,:),'FaceAlpha',.3, 'Edgecolor', 'none','HandleVisibility','off');
x_ = [Dataset.events.time{ee,2} flip(Dataset.events.time{ee,2})];
y_ = [CI_events{ee,2}(2,:),flip(CI_events{ee,2}(3,:))];
patch(x_, y_, colors_geno(2,:),'FaceAlpha',.3, 'Edgecolor', 'none','HandleVisibility','off');
p1 = plot(Dataset.events.time{ee,1},CI_events{ee,1}(1,:),'-','Color',colors_geno(1,:));
p2 = plot(Dataset.events.time{ee,2},CI_events{ee,2}(1,:),'-','Color',colors_geno(2,:)); 
currplt = double(Sig_events{ee,1}); currplt(currplt~=1) = NaN;
plot(Dataset.events.time{ee,1},currplt*lim_up,'-','Color',colors_geno(1,:),'LineWidth',2); 
currplt = double(Sig_events{ee,2}); currplt(currplt~=1) = NaN;
plot(Dataset.events.time{ee,2},currplt*(lim_up+0.5),'-','Color',colors_geno(2,:),'LineWidth',2); 
currplt = double(sig_perm); currplt(currplt~=1) = NaN;
plot(Dataset.events.time{ee,2},currplt*(lim_up+1),'-','Color','k','LineWidth',2)
%currplt = double(sig_bCI); currplt(currplt~=1) = NaN;
%plot(Dataset.events.time{ee,2},currplt*(lim_up+1.5),'-','Color','k','LineWidth',2)
ylim([-inf,lim_up+2]);
xlim(plot_Xlimits(ee,:))
xlabel('Time (s)'); ylabel('Z-score');
legend([p1,p2],{geno_names{1},geno_names{2}},'Location','northwest')
title(events_display{ee})
subplot(nlin,ncol,ncol+1) %Average z score before and after TS
before1 = mean(data1(:,Dataset.events.time{ee,1}>=AUC_limits(ee,1)&Dataset.events.time{ee,1}<=AUC_limits(ee,2)),2,'omitnan');
before2 = mean(data2(:,Dataset.events.time{ee,1}>=AUC_limits(ee,1)&Dataset.events.time{ee,1}<=AUC_limits(ee,2)),2,'omitnan');
after1 = mean(data1(:,Dataset.events.time{ee,1}>=AUC_limits(ee,3)&Dataset.events.time{ee,1}<=AUC_limits(ee,4)),2,'omitnan');
after2 = mean(data2(:,Dataset.events.time{ee,1}>=AUC_limits(ee,3)&Dataset.events.time{ee,1}<=AUC_limits(ee,4)),2,'omitnan');
errorbar([1 2]-0.2,[mean(before1),mean(after1)],[std(before1)/sqrt(length(before1)),std(after1)/sqrt(length(after1))],'.','Color',colors_geno(1,:),'LineWidth',1); hold on
errorbar([1 2]+0.2,[mean(before2),mean(after2)],[std(before2)/sqrt(length(before2)),std(after2)/sqrt(length(after2))],'.','Color',colors_geno(2,:),'LineWidth',1); hold on
bar([1 2]-0.2,[mean(before1),mean(after1)],0.3,'EdgeColor',colors_geno(1,:),'FaceColor','w','LineWidth',1); hold on
bar([1 2]+0.2,[mean(before2),mean(after2)],0.3,'EdgeColor',colors_geno(2,:),'FaceColor','w','LineWidth',1); hold on
%plot([1 2]-0.2,[before1,after1],'.','Color',[0.8 0.8 0.8]); hold on
%plot([1 2]+0.2,[before2,after2],'.','Color',[0.8 0.8 0.8])
[~,p] = ttest2(before1,before2);
if p<0.001; txt = '***'; elseif p<0.01; txt = '**'; elseif p<0.05; txt = '*'; else; txt = 'ns'; end
ypos = max([mean(before1),mean(before2)]+[std(before1)/sqrt(length(before1)),std(before2)/sqrt(length(before2))]);
if ypos<0; ypos = 0.4*abs(ypos); end
if ~strcmp(txt,'ns'); plot([-0.2 +0.2]+1, ypos*1.05*[1 1],'-k'); text(1,ypos*1.1,txt,'HorizontalAlignment','center'); end
[~,p] = ttest2(after1,after2);
if p<0.001; txt = '***'; elseif p<0.01; txt = '**'; elseif p<0.05; txt = '*'; else; txt = 'ns'; end
ypos = max([mean(after1),mean(after2)]+[std(after1)/sqrt(length(after1)),std(after2)/sqrt(length(after2))]);
if ypos<0; ypos = 0.4*abs(ypos); end
if ~strcmp(txt,'ns'); plot([-0.2 +0.2]+2, ypos*1.05*[1 1],'-k'); text(2,ypos*1.1,txt,'HorizontalAlignment','center'); end
xticks([1 2]); xticklabels({[num2str(AUC_limits(ee,1)),' - ',num2str(AUC_limits(ee,2)),' s'],...
                            [num2str(AUC_limits(ee,3)),' - ',num2str(AUC_limits(ee,4)),' s']});
xtickangle(45); ylabel('Average z-score')
subplot(nlin,ncol,ncol+2) %AUC z score before and after TS
before1 = sum(data1(:,Dataset.events.time{ee,1}>=AUC_limits(ee,1)&Dataset.events.time{ee,1}<=AUC_limits(ee,2)),2,'omitnan');
before2 = sum(data2(:,Dataset.events.time{ee,1}>=AUC_limits(ee,1)&Dataset.events.time{ee,1}<=AUC_limits(ee,2)),2,'omitnan');
after1 = sum(data1(:,Dataset.events.time{ee,1}>=AUC_limits(ee,3)&Dataset.events.time{ee,1}<=AUC_limits(ee,4)),2,'omitnan');
after2 = sum(data2(:,Dataset.events.time{ee,1}>=AUC_limits(ee,3)&Dataset.events.time{ee,1}<=AUC_limits(ee,4)),2,'omitnan');
errorbar([1 2]-0.2,[mean(before1),mean(after1)],[std(before1)/sqrt(length(before1)),std(after1)/sqrt(length(after1))],'.','Color',colors_geno(1,:),'LineWidth',1); hold on
errorbar([1 2]+0.2,[mean(before2),mean(after2)],[std(before2)/sqrt(length(before2)),std(after2)/sqrt(length(after2))],'.','Color',colors_geno(2,:),'LineWidth',1); hold on
bar([1 2]-0.2,[mean(before1),mean(after1)],0.3,'EdgeColor',colors_geno(1,:),'FaceColor','w','LineWidth',1); hold on
bar([1 2]+0.2,[mean(before2),mean(after2)],0.3,'EdgeColor',colors_geno(2,:),'FaceColor','w','LineWidth',1); hold on
%plot([1 2]-0.2,[before1,after1],'.','Color',[0.8 0.8 0.8]); hold on
%plot([1 2]+0.2,[before2,after2],'.','Color',[0.8 0.8 0.8])
[~,p] = ttest2(before1,before2);
if p<0.001; txt = '***'; elseif p<0.01; txt = '**'; elseif p<0.05; txt = '*'; else; txt = 'ns'; end
ypos = max([mean(before1),mean(before2)]+[std(before1)/sqrt(length(before1)),std(before2)/sqrt(length(before2))]);
if ypos<0; ypos = 0.4*abs(ypos); end
if ~strcmp(txt,'ns'); plot([-0.2 +0.2]+1, ypos*1.05*[1 1],'-k'); text(1,ypos*1.1,txt,'HorizontalAlignment','center'); end
[~,p] = ttest2(after1,after2);
if p<0.001; txt = '***'; elseif p<0.01; txt = '**'; elseif p<0.05; txt = '*'; else; txt = 'ns'; end
ypos = max([mean(after1),mean(after2)]+[std(after1)/sqrt(length(after1)),std(after2)/sqrt(length(after2))]);
if ypos<0; ypos = 0.4*abs(ypos); end
if ~strcmp(txt,'ns'); plot([-0.2 +0.2]+2, ypos*1.05*[1 1],'-k'); text(2,ypos*1.1,txt,'HorizontalAlignment','center'); end
xticks([1 2]); xticklabels({[num2str(AUC_limits(ee,1)),' - ',num2str(AUC_limits(ee,2)),' s'],...
                            [num2str(AUC_limits(ee,3)),' - ',num2str(AUC_limits(ee,4)),' s']});
xtickangle(45); ylabel('AUC')
subplot(nlin,ncol,ncol+3) %transient rate before and after TS
before1 = sum(data1t(:,Dataset.events.time{ee,1}>=AUC_limits(ee,1)&Dataset.events.time{ee,1}<=AUC_limits(ee,2)),2,'omitnan');
before2 = sum(data2t(:,Dataset.events.time{ee,1}>=AUC_limits(ee,1)&Dataset.events.time{ee,1}<=AUC_limits(ee,2)),2,'omitnan');
after1 = sum(data1t(:,Dataset.events.time{ee,1}>=AUC_limits(ee,3)&Dataset.events.time{ee,1}<=AUC_limits(ee,4)),2,'omitnan');
after2 = sum(data2t(:,Dataset.events.time{ee,1}>=AUC_limits(ee,3)&Dataset.events.time{ee,1}<=AUC_limits(ee,4)),2,'omitnan');
errorbar([1 2]-0.2,[mean(before1),mean(after1)],[std(before1)/sqrt(length(before1)),std(after1)/sqrt(length(after1))],'.','Color',colors_geno(1,:),'LineWidth',1); hold on
errorbar([1 2]+0.2,[mean(before2),mean(after2)],[std(before2)/sqrt(length(before2)),std(after2)/sqrt(length(after2))],'.','Color',colors_geno(2,:),'LineWidth',1); hold on
bar([1 2]-0.2,[mean(before1),mean(after1)],0.3,'EdgeColor',colors_geno(1,:),'FaceColor','w','LineWidth',1); hold on
bar([1 2]+0.2,[mean(before2),mean(after2)],0.3,'EdgeColor',colors_geno(2,:),'FaceColor','w','LineWidth',1); hold on
%plot([1 2]-0.2,[before1,after1],'.','Color',[0.8 0.8 0.8]); hold on
%plot([1 2]+0.2,[before2,after2],'.','Color',[0.8 0.8 0.8])
[~,p] = ttest2(before1,before2);
if p<0.001; txt = '***'; elseif p<0.01; txt = '**'; elseif p<0.05; txt = '*'; else; txt = 'ns'; end
ypos = max([mean(before1),mean(before2)]+[std(before1)/sqrt(length(before1)),std(before2)/sqrt(length(before2))]);
if ypos<0; ypos = 0.4*abs(ypos); end
if ~strcmp(txt,'ns'); plot([-0.2 +0.2]+1, ypos*1.05*[1 1],'-k'); text(1,ypos*1.1,txt,'HorizontalAlignment','center'); end
[~,p] = ttest2(after1,after2);
if p<0.001; txt = '***'; elseif p<0.01; txt = '**'; elseif p<0.05; txt = '*'; else; txt = 'ns'; end
ypos = max([mean(after1),mean(after2)]+[std(after1)/sqrt(length(after1)),std(after2)/sqrt(length(after2))]);
if ypos<0; ypos = 0.4*abs(ypos); end
if ~strcmp(txt,'ns'); plot([-0.2 +0.2]+2, ypos*1.05*[1 1],'-k'); text(2,ypos*1.1,txt,'HorizontalAlignment','center'); end
xticks([1 2]); xticklabels({[num2str(AUC_limits(ee,1)),' - ',num2str(AUC_limits(ee,2)),' s'],...
                            [num2str(AUC_limits(ee,3)),' - ',num2str(AUC_limits(ee,4)),' s']});
xtickangle(45); ylabel('Transient rate (ev/min)')
subplot(nlin,ncol,ncol+4) %max z score value before and after TS
before1 = max(data1(:,Dataset.events.time{ee,1}>=AUC_limits(ee,1)&Dataset.events.time{ee,1}<=AUC_limits(ee,2)),[],2,'omitnan');
before2 = max(data2(:,Dataset.events.time{ee,1}>=AUC_limits(ee,1)&Dataset.events.time{ee,1}<=AUC_limits(ee,2)),[],2,'omitnan');
after1 = max(data1(:,Dataset.events.time{ee,1}>=AUC_limits(ee,3)&Dataset.events.time{ee,1}<=AUC_limits(ee,4)),[],2,'omitnan');
after2 = max(data2(:,Dataset.events.time{ee,1}>=AUC_limits(ee,3)&Dataset.events.time{ee,1}<=AUC_limits(ee,4)),[],2,'omitnan');
errorbar([1 2]-0.2,[mean(before1),mean(after1)],[std(before1)/sqrt(length(before1)),std(after1)/sqrt(length(after1))],'.','Color',colors_geno(1,:),'LineWidth',1); hold on
errorbar([1 2]+0.2,[mean(before2),mean(after2)],[std(before2)/sqrt(length(before2)),std(after2)/sqrt(length(after2))],'.','Color',colors_geno(2,:),'LineWidth',1); hold on
bar([1 2]-0.2,[mean(before1),mean(after1)],0.3,'EdgeColor',colors_geno(1,:),'FaceColor','w','LineWidth',1); hold on
bar([1 2]+0.2,[mean(before2),mean(after2)],0.3,'EdgeColor',colors_geno(2,:),'FaceColor','w','LineWidth',1); hold on
%plot([1 2]-0.2,[before1,after1],'.','Color',[0.8 0.8 0.8]); hold on
%plot([1 2]+0.2,[before2,after2],'.','Color',[0.8 0.8 0.8])
[~,p] = ttest2(before1,before2);
if p<0.001; txt = '***'; elseif p<0.01; txt = '**'; elseif p<0.05; txt = '*'; else; txt = 'ns'; end
ypos = max([mean(before1),mean(before2)]+[std(before1)/sqrt(length(before1)),std(before2)/sqrt(length(before2))]);
if ypos<0; ypos = 0.4*abs(ypos); end
if ~strcmp(txt,'ns'); plot([-0.2 +0.2]+1, ypos*1.05*[1 1],'-k'); text(1,ypos*1.1,txt,'HorizontalAlignment','center'); end
[~,p] = ttest2(after1,after2);
if p<0.001; txt = '***'; elseif p<0.01; txt = '**'; elseif p<0.05; txt = '*'; else; txt = 'ns'; end
ypos = max([mean(after1),mean(after2)]+[std(after1)/sqrt(length(after1)),std(after2)/sqrt(length(after2))]);
if ypos<0; ypos = 0.4*abs(ypos); end
if ~strcmp(txt,'ns'); plot([-0.2 +0.2]+2, ypos*1.05*[1 1],'-k'); text(2,ypos*1.1,txt,'HorizontalAlignment','center'); end
xticks([1 2]); xticklabels({[num2str(AUC_limits(ee,1)),' - ',num2str(AUC_limits(ee,2)),' s'],...
                            [num2str(AUC_limits(ee,3)),' - ',num2str(AUC_limits(ee,4)),' s']});
xtickangle(45); ylabel('Peak z-score')
%save image
FigName = ['Results',filesep,'D1vD2_',events_names{ee}];
saveas(gcf,FigName,'png')
saveas(gcf,FigName,'pdf')
savefig(gcf,FigName);

end