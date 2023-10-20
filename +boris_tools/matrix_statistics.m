function struct = matrix_statistics(matrix, bsl_i1, bsl_i2)
        
    struct.matrix = matrix;

    struct.matrix_mean = mean(matrix);
    struct.matrix_std  = std(matrix);

    struct.bsl_mean = mean(matrix(:,bsl_i1:bsl_i2),2);
    struct.bsl_std = std(matrix(:,bsl_i1:bsl_i2),0,2);

    [r,c]=size(matrix);

    struct.zscored_matrix = matrix - repmat(struct.bsl_mean,1,c);
    struct.zscored_matrix = struct.zscored_matrix./repmat(struct.bsl_std,1,c);

    struct.z_mean = mean(struct.zscored_matrix);
    struct.z_std  = std(struct.zscored_matrix);

end