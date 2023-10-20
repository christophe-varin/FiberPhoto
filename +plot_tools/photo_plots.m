function photo_plots(data, plotname)

    if strcmp(plotname,'deinterleaved signals')
        fig=figure();
        title('deinterleaved data')
        hold on
        plot(data.dein_signals.time,data.dein_signals.iso,'m')
        plot(data.dein_signals.time,data.dein_signals.physio,'b')
        legend({'iso', 'physio'})
        plot_tools.smart_save_figures(fig, data.figure, 'deinterleaved_data')
    end
    
    if strcmp(plotname,'fit iso')
        fig=figure();
        title('Isosbestic Fit')
        hold on
        plot(data.dein_signals.time,data.dein_signals.fit_iso,'m')
        plot(data.dein_signals.time,data.dein_signals.physio,'b')
        legend({'iso (fit)', 'physio'})
        plot_tools.smart_save_figures(fig, data.figure, 'fit_iso')
    end
    
    if strcmp(plotname,'dff_debug')
        plot_dff_debug(data.dein_signals.time, data.dein_signals.iso, data.dein_signals.fit_iso, data.dein_signals.physio, data.dff, data.output)
    end
    
    if strcmp(plotname,'dff')
        fig=figure();
        title('DFF')
        hold on
        plot(data.dein_signals.time,data.dff,'g')
        legend({'dff'})
        plot_tools.smart_save_figures(fig, data.figure, 'dff')
    end    
 
    if strcmp(plotname,'transients')
        fig=figure();
        title('Transients')
        hold on
        plot_tools.plot_transients(data.transients,data.dein_signals.time, data.dff,'dff',0)
        plot_tools.smart_save_figures(fig, data.figure, 'transients');
    end    
     
end


function plot_dff_debug(t, iso, iso_fit, physio, dff, output)
fig=figure();
subplot(2,1,1)
title('raw')
hold on
plot(t,(iso))
plot(t,(iso_fit))
plot(t,(physio))
legend('iso','iso_fit','physio');
subplot(2,1,2)
title('dff')
hold on
plot(t,norm_01(physio))
plot(t,dff)
legend('physio','dff');
plot_tools.smart_save_figures(fig, output, 'dff_debug')
end


function sig = norm_01(sig)
    sig = sig - min(sig);
    sig = sig / max(sig);
end





