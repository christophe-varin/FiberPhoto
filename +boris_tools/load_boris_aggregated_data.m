function boris_data = load_boris_aggregated_data(filepath, camera_TTL_raising_times)
% This function take a path to a boris csv file and return the headers
% of the columns in header_raw as well as all the data

eventTable = readtable(filepath,'Filetype','text','Delimiter','\t');
tableSize = size(eventTable,1);

timeGap = camera_TTL_raising_times(1);

boris_data = [];
boris_data.video.duration_sec = eventTable.TotalLength(1);
boris_data.video.FPS = eventTable.FPS(1);
events_names = unique(eventTable.Behavior);
nEvents = size(events_names,1);

for iEvent = 1:nEvents
    idx = cellfun(@(x) x==events_names{iEvent}, eventTable.Behavior, 'UniformOutput', 1);
    idx = find(idx==1);
    idx = find(strcmp(events_names{iEvent},eventTable.Behavior));
    n_idx = size(idx,1);
    boris_data.events(iEvent).name = string(events_names(iEvent));
    boris_data.events(iEvent).start = [];
    boris_data.events(iEvent).stop = [];
    boris_data.events(iEvent).duration = [];
    for j=1:n_idx
        boris_data.events(iEvent).start(end+1)= eventTable.Start_s_(idx(j))+timeGap;
        boris_data.events(iEvent).stop(end+1)= eventTable.Stop_s_(idx(j))+timeGap;
    end
end


end
