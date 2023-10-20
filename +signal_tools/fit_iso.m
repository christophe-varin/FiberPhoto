function fit_ = fit_iso(iso, physio)
        %% fit iso to fluo gcamp (fit sig1 to sig2)
        N=1; % polynomial coef for linear
        P = polyfit(iso, physio, N);
        fit_ = iso*P(1)+P(2);
end