function info=parse_filename(f,varargin)

    if isempty(varargin)
        info = parse_roman_filenames(f);
    else
        if strcmp(varargin{1},'Anna')
            info = parse_anna_filenames(f);
        elseif strcmp(varargin{1},'Roman')
            info = parse_roman_filenames(f);
        end
    end
    
end

function info = parse_anna_filenames(f)
f = split(f,'.');
f = f{1};
%f = '27481_F_20220506_sess01_rec1_Ymaze_C1.csv'
fields = split(f,'_');
info.prefix = f;
info.mouse = fields{1};
info.sex = fields{2};
info.date = fields{3};
info.session = fields{4}(5:end);
info.rec = fields{5}(4:end);
info.suppl = fields{6};
info.peptide = fields{7};
end


function info = parse_roman_filenames(f)
%f = '45269_D1_T2_20_08_21.csv'
f = split(f,'.');
f = f{1};
fields = split(f,'_');
info.prefix = f;
info.mouse = fields{1};
info.genotype = fields{2};
info.trial = fields{3};
info.day = fields{4};
info.month = fields{5};
info.year = fields{6};

end
