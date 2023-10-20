function s= table_transient(files)

for k = 1 : length(files)
    fName = files(k).name;
    fFolder = files(k).folder;
    fullname = fullfile(fFolder,fName);
    load(fullname)
    file_name = fullname ;
    info_file_name = split(file_name,'.');
    info_file_name = info_file_name{1};
    % Group transient variables table in one Transient table
    T1=table(s.transients.time, s.transients.loc, s.transients.peak, s.transients.width, s.transients.prominence); 
    T2 = renamevars(T1, ["Var1","Var2","Var3","Var4","Var5"], ["Time","Index","Peak","Width","Prominence"]);
    % Export table to XLS file
    if ~exist([info_file_name '_Table_transients.xls'],"file")
    writetable(T2, [info_file_name '_Table_transients.xls'], 'WriteVariableNames',true, 'FileType','spreadsheet');
    end 
end