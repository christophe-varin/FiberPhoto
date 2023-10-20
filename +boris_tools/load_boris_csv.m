function boris_events = load_boris_csv(filepath, camera_TTL_raising_times)
% This function take a path to a boris csv file and return the headers
% of the columns in header_raw as well as all the data
n_line_header = 1; % In 2021 Doric csv file has two lines of header
fp = fopen(filepath,'r'); % Open the csv file in read mode 'r'
for i=1:n_line_header, tline = fgetl(fp); end  %owerwrite first line, only second line has an inerrest
header = split(tline,','); % split by coma (csv file) and return the header of each column in an cell array call header
data = dlmread(filepath,',',2,0); % read everything from the 3 line (skip 2) without skipiing columns (0) and place it in a 2D matrix called data


t = data(:,1) + camera_TTL_raising_times(1);
sfreq = 1/median(diff(t));

boris_events = [];
for i=2:size(header,1)
    boris_events(i-1).name = header{i};
    ts = t(find(data(:,i)==1),1);
    ts = [0; ts];
    d = diff(ts);
    min_gap = (1/sfreq)*2;
    ts = ts(find(d>min_gap)+1);
    boris_events(i-1).ts = ts;
end

end

