function plot_transients(transients_,t,sig,sig_str, plot_th)

    locs_ = transients_.loc;
    w_    = transients_.width;
    p_    = transients_.prominence;
    pks_  = transients_.peak;
    th    = transients_.filtered_sig_median + transients_.oneMAD;
    th2 = transients_.filtered_sig_median + (transients_.oneMAD *2);

    max_ = max(sig);
    min_ = min (sig);
    amp_ = max_ - min_;
    sup_ = max_ + amp_/5;

    hold on
    plot(t,sig,'g')
    if plot_th
        plot([t(1) t(end)], [th,th], 'k:')
        plot([t(1) t(end)], [th2,th2], 'k:')   
    end

    for k=1:size(locs_,1)
        i = locs_(k);
        x_ = t(i);
        y_ = sig(i);
        plot([x_ x_],[y_ sup_], 'm')
        plot(x_,sup_,'m*')   
        text(x_,sup_ + (amp_/10),sprintf('w=%2.2f, p=%2.2f',w_(k),p_(k)),'FontSize', 6,'Rotation',90);
    end
    legend({sig_str})

    ylim([(min_ - (amp_/4)) (max_ + (amp_))])
end
