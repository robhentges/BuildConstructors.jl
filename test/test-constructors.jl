using Test
using BuildConstructors
using Distributions


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
