include("../src/construct_model.jl")
include("../src/construct_primitives.jl")

include("../src/load_model_from_json.jl")

constructor, pars = load_prb_model_from_json("../../data/database_test.json")
model = build_model(constructor, pars)


#=c_comb = ConstructorOfPRBModel(
	ConstructorOfBW("m1", "Γ1", (1.1, 2.5)),
	ConstructorOfGaussian("μ1", "σ1", (-0.6, 0.6)),
	ConstructorOfPol1("c1", (1.1, 2.5)),
	"fs1"
)

starting_pars = (m1=2.02, Γ1=0.1, μ1=0.0, σ1=0.1, c1=0.01, fs1 = 0.5)
model = build_model(c_comb, starting_pars)

@testset "Constructor of mixture model" begin
	@test pdf(model, 2.0) ≈ 1.7976746918241435 
end=#

#=cM_running_gw = ConstructorOfPRBModel(
    ConstructorOfFlatte(Fixed(-7.66), Running("g"), Fixed(1.88), (1.0, 2.6)),
    ConstructorOfCBpSECH(Fixed(0.002795), Fixed(2.48), Fixed(474), Fixed(8.1), Fixed(2.0), Fixed(1.3505), Fixed(0.5909), Running("w"), (-0.5, 0.5)),
    ConstructorOfPol1(Fixed(0.1), (1.0, 2.6)),
    Fixed(0.5),
    (1.1, 2.5)
)

#using X3872Flatte: AJψππ, FlatteModel

using Test

model = build_model(cM_running_gw, (g = 0.115, w = 0.5,))
@test pdf(model, 1.1) ≈ 0.7084462317465321=#
