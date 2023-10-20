function [animal_name,dopaminergic_status] = parse_animal_foldername_roman(foldername)
    tmp = split(foldername,'D');
    animal_name = tmp{1};
    dopaminergic_status = tmp{2};
end

