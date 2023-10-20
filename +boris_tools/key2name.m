function name = key2name(key)
    keys = ['a','z','e','r','s','d','f','v','g','h','t'];
    events_names = {'Basal','door_eat','go_eat','eat','door_run','go_run','w_on','w_on2','w_off','w_blk','plt1'};
    name = events_names{keys==char(key)};
end
