struct ConstructorOfMistureModel{PHYS,RES,BG}
	model_p::PHYS
	model_r::RES
	model_b::BG
	name_of_fs::String
end

function build_model(c::ConstructorOfMistureModel, pars)
	p = build_model(c.model_p, pars)
	r = build_model(c.model_r, pars)
	b = build_model(c.model_b, pars)
	r_conv_p = fft_convolve(r, p)
	customary_name = c.name_of_fs
	fs = getproperty(pars, Symbol(customary_name))
	MixtureModel([r_conv_p, b], [fs, 1-fs])
end
