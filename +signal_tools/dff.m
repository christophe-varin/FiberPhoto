function dff_ = dff(t, iso_fit, physio)
    min_ = min([min(physio), min(iso_fit)]);
    physio = physio - min_ + 1;
    iso_fit = iso_fit - min_ + 1;
    dff_ = (physio-iso_fit)./iso_fit;
end
