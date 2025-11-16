
struct ConstructorOfPRBModel{PHYS,RES,BG,T} <: AbstractConstructor
    model_p::PHYS
    model_r::RES
    model_b::BG
    description_of_fs::T
    support::Tuple{Float64,Float64} # not same as model support, rather actual fit range
end

function build_model(c::ConstructorOfPRBModel, pars)
    p = build_model(c.model_p, pars)
    r = build_model(c.model_r, pars)
    b = build_model(c.model_b, pars)
    r_conv_p = fft_convolve(r, p)
    fs = value(c.description_of_fs; pars)
    truncated(MixtureModel([r_conv_p, b], [fs, 1-fs]), c.support[1], c.support[2])
end
