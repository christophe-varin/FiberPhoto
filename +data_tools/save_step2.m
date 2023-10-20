function save_step2(s,step2)
step1 = s ;
save([s.figure.folder filesep s.figure.prefix '_step2.mat'],'step1','step2');
end