function smart_save_figures(fig, params, title_suffix)
    % create desitnatoin folder where the figure will be saved if this
    % folder does not exists already
    if ~exist(params.folder)
        mkdir(params.folder)
    end
    % save the figure ion a png format
    p = [params.folder filesep [params.prefix '_'  title_suffix '.png']];
    if params.savepng && ~exist(p, 'file')
        print(fig,p, '-dpng');
    end
    %save the figurte in a fig format
    p = [params.folder filesep [params.prefix '_'  title_suffix '.fig']];
    if params.savefig && ~exist(p, 'file')     
        saveas(fig,p)
    end
    %close the figure if requested in the parameters
    if params.closefig
        close(fig);
    end
end
