
using Plots


# ╔═╡ 715c5852-348e-47d2-a0cc-174fa12eb9e1
md"""
## Manual construction
"""

# ╔═╡ e5afa364-602c-47d5-8f26-894704efb900
c_comb = ConstructorOfMistureModel(
	ConstructorOfBW("m1", "Γ1", (1.1, 2.5)),
	ConstructorOfGaussian("μ1", "σ1", (-0.6, 0.6)),
	ConstructorOfPol1("c1", (1.1, 2.5)),
	"fs1"
)

# ╔═╡ 1eeb67d7-3dbf-4f4b-9e29-cc2f5bcd5226
let 
	starting_pars = (m1=2.02, Γ1=0.1, μ1=0.0, σ1=0.1, c1=0.01, fs1 = 0.5)
	model = build_model(c_comb, starting_pars)
	plot(x->pdf(model, x), 1.0, 2.6, fill=0, fillalpha=0.3)
end

# ╔═╡ 469f7491-3f8f-43ce-b453-3ac6f1da6799
md"""
## DataBase
"""

# ╔═╡ c97bffbe-8c2a-4552-8476-13c4b49658b2
database = LittleDict(
	"physical" => LittleDict(
		"bw" => (
			method = "ConstructorOfBW",
			pars = (m=2.1, Γ=0.1)
		),
	),
	"sets" => LittleDict(
		"bin1" => LittleDict(
			"RES" => (
				method = "ConstructorOfZeroGaussian",
				pars = (σ=0.1,),
				support = (-0.6, 0.6)
			),
			"BG" => (
				method = "ConstructorOfPol1",
				pars = (c1=0.1,),
				support = (1.1, 2.5)
			)
		),
		"bin2" => LittleDict(
			"RES" => (
				primitive = "ConstructorOfGaussian",
				pars = (μ=0.0, σ=0.2),
				support = (-0.6, 0.6)
			),
			"BG" => (
				primitive = "ConstructorOfPol1",
				pars = (c1=0.2,),
				support = (1.1, 2.5)
			)
		)
	)
);


# ╔═╡ 23de7e19-cf28-4007-a563-091865d7d99f
let 
	c_comp_auto, starting_pars = build_model_constuctor("bw", "bin1"; database)
	model = build_model(c_comp_auto, starting_pars)
	@show starting_pars
	plot(x->pdf(model, x), 1.0, 2.6, fill=0, fillalpha=0.3)
end
