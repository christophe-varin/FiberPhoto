function plot_heat_maps(Dataset,geno_names,rec_type,events_names,events_plot)

Xnew = -(40*10):1:(60*10);
for gg=1:1:length(geno_names) %loop on genotypes
    for rr=1:1:length(rec_type) %loop on eat or run sessions
        figure('Name',[geno_names{gg},': Rep. trials ',rec_type{rr}])
        %align trials to door opening
        trials_max = min(tot_trials_plot,size(Dataset.whole_dff.data{rr,gg},2));
        Trials = Dataset.whole_dff.data{rr,gg}(:,1:trials_max);
        Ev_tags = Dataset.whole_dff.tags{rr,gg}(:,1:trials_max);
        Trials_aligned = NaN(size(Trials,2),length(Xnew));
        for tt=1:1:size(Trials,2)
            ind_door = find(Ev_tags(:,tt)==find(strcmp(events_names,'door_eat'))|Ev_tags(:,tt)==find(strcmp(events_names,'door_run')));
            if ~isempty(ind_door)
                temp_vec = Trials(:,tt); 
                temp_vec = (temp_vec-mean(temp_vec(1:(ind_door-10)),'omitnan'))/std(temp_vec(1:(ind_door-10)),'omitnan');
                temp_vec = circshift(temp_vec,find(Xnew==0)-ind_door); %door open at Xnew = 0 s
                Trials_aligned(tt,:) = temp_vec(1:length(Xnew)); 
            end
        end
        %get rid of NaN filled trials
        trials_indices = 1:1:size(Trials_aligned,1);
        trials_indices(sum(isnan(Trials_aligned),2)==size(Trials_aligned,2)) = [];
        imagesc(Trials_aligned(trials_indices,:)); hold on
        colormap('jet'); caxis([-6 6]);
        plot(find(Xnew==0)*[1 1],[1 trials_max],'-k')
        keepEE = cell(10,1);
        for ee=[2 3 5 6 7 8 9 10]; keepEE{ee} = NaN(length(trials_indices),10);end
        for tt=1:1:length(trials_indices)
            ind_door = find(Ev_tags(:,trials_indices(tt))==find(strcmp(events_names,'door_eat'))|Ev_tags(:,trials_indices(tt))==find(strcmp(events_names,'door_run')));
            if ~isempty(ind_door)
                for ee=[2 3 5 6 7 8 9 10]
                    ind_ev = find(Ev_tags(:,trials_indices(tt))==find(strcmp(events_names,events_names{ee})));
                    if ~isempty(ind_ev)
                        ind_ev = ind_ev-ind_door+find(Xnew==0);
                        
                        %plot individual events
                        plot(ind_ev,tt*ones(size(ind_ev)),events_plot{ee},'Color',[0 0 0],'MarkerSize',3,'MarkerFaceColor','k')
                        ind_ev(ind_ev>length(Xnew)) = [];
                        keepEE{ee}(tt,1:length(ind_ev)) = Xnew(ind_ev)/10;
                    end
                end
            end
        end
        title([geno_names{gg},': Rep. trials ',rec_type{rr}])
        colorbar
        xlim([0 length(Xnew)]);
        set(gca,'XTick',(1:200:length(Xnew)),'XTickLabel',Xnew(1:200:end)/10)
        xlabel('Time from door open (s)'); ylabel('Trials z-scored baseline');
        if rr==1
            ee=2; pw{1} = plot(nan,events_plot{ee},'Color',[0 0 0],'MarkerSize',3,'MarkerFaceColor','k');
            ee=10; pw{2} = plot(nan,events_plot{ee},'Color',[0 0 0],'MarkerSize',3,'MarkerFaceColor','k');
            ee=3; pw{3} = plot(nan,events_plot{ee},'Color',[0 0 0],'MarkerSize',3,'MarkerFaceColor','k');
            h = legend([pw{:}],{'go eat','first pellet','eat'},'Location','northeastoutside'); 
        elseif rr==2
            ee=5; pw{1} = plot(nan,events_plot{ee},'Color',[0 0 0],'MarkerSize',3,'MarkerFaceColor','k');
            ee=6; pw{2} = plot(nan,events_plot{ee},'Color',[0 0 0],'MarkerSize',3,'MarkerFaceColor','k');
            ee=8; pw{3} = plot(nan,events_plot{ee},'Color',[0 0 0],'MarkerSize',3,'MarkerFaceColor','k');
            h = legend([pw{:}],{'go run','run start','run stop'},'Location','northeastoutside'); 
        end
        
        saveas(gcf,FigName,'png')
        saveas(gcf,FigName,'pdf')
        savefig(gcf,FigName);
    end
end

end