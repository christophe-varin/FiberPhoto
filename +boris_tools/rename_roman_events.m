function boris_data = rename_roman_events(boris_data)
boris_events = boris_data.events;
n_events = max(size(boris_data.events));
% Loop on each event category
for i_event = 1:n_events
    boris_data.events(i_event).name = boris_tools.key2name(boris_data.events(i_event).name);
end
end