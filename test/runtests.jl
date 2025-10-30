using OrderedCollections
using BuildConstructors
using Distributions
using Plots
using Test

c_comb = ConstructorOfMixtureModel(
	ConstructorOfBW("m1", "Γ1", (1.1, 2.5)),
	ConstructorOfGaussian("μ1", "σ1", (-0.6, 0.6)),
	ConstructorOfPol1("c1", (1.1, 2.5)),
	"fs1"
)

starting_pars = (m1=2.02, Γ1=0.1, μ1=0.0, σ1=0.1, c1=0.01, fs1 = 0.5)
model = build_model(c_comb, starting_pars)

@testset "Constructor of mixture model" begin
	@test pdf(model, 2.0) ≈ 1.7976746918241435 
end


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
				method = "ConstructorOfGaussian",
				pars = (μ=0.0, σ=0.2),
				support = (-0.6, 0.6)
			),
			"BG" => (
				method = "ConstructorOfPol1",
				pars = (c1=0.2,),
				support = (1.1, 2.5)
			)
		)
	)
);


c_comp_auto, starting_pars = build_model_constructor("bw", "bin1"; database)
model = build_model(c_comp_auto, starting_pars)

@testset "Regression test for bin1" begin
	@test starting_pars == (m = 2.1, Γ = 0.1, σ_bin1 = 0.1, c1_bin1 = 0.1, fs1 = 0.9)
	@test pdf(model, 2.2) ≈ 1.9388939628683186
end

c_comp_auto, starting_pars = build_model_constructor("bw", "bin2"; database)
model = build_model(c_comp_auto, starting_pars)

@testset "Regression test for bin2" begin
	@test starting_pars == (m = 2.1, Γ = 0.1, μ_bin2 = 0.0, σ_bin2 = 0.2, c1_bin2 = 0.2, fs1 = 0.9)
	@test pdf(model, 2.2) ≈ 1.4758514528240432
end
