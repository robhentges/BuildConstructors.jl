@with_parameters(
    PRBModel;
    fs::P,
    model_p,
    model_r,
    model_b,
    support::Tuple{Float64,Float64},
    begin
        p = build_model(_.model_p, pars)
        r = build_model(_.model_r, pars)
        b = build_model(_.model_b, pars)
        r_conv_p = fft_convolve(r, p)
        truncated(MixtureModel([r_conv_p, b], [fs, 1-fs]), _.support[1], _.support[2])
    end
)
