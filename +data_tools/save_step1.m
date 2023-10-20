function save_step1(step1)
if isfield(step1.raw_signals,'digSig3_on_idx')
	step1.dio3.raising_times = step1.raw_signals.time(step1.raw_signals.digSig3_on_idx);
end
	step1.raw_signals = [];
	save([step1.figure.folder filesep step1.figure.prefix '_step1.mat'],'step1');
end