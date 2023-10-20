function struct = matrix_statistics_zscored_event(matrix, bsl_i1, bsl_i2, event_bsl_mean, event_bsl_std)
        
        struct.matrix = matrix;

        struct.matrix_mean = mean(matrix);
        struct.matrix_std  = std(matrix);

        struct.bsl_mean = mean(matrix(:,bsl_i1:bsl_i2),2);
        struct.bsl_std = std(matrix(:,bsl_i1:bsl_i2),0,2);

        [r,c]=size(matrix);

        struct.zscored_matrix = matrix - repmat(struct.bsl_mean,1,c);
        struct.zscored_matrix = struct.zscored_matrix./repmat(struct.bsl_std,1,c);

        struct.zscored_event_basal_matrix = matrix - repmat(event_bsl_mean,1,c);
        struct.zscored_event_basal_matrix = struct.zscored_event_basal_matrix./repmat(event_bsl_std,1,c);
        
        struct.z_mean = mean(struct.zscored_matrix);
        struct.z_std  = std(struct.zscored_matrix);

        struct.z_event_mean = mean(struct.zscored_event_basal_matrix);
        struct.z_event_std  = std(struct.zscored_event_basal_matrix);
    end