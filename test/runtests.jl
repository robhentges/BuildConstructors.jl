#=using Test


include("../src/construct_model.jl")
include("../src/construct_primitives.jl")


cM_running_gw = ConstructorOfPRBModel(
    ConstructorOfFlatte(Fixed(-7.66), Running("g"), Fixed(1.88), (1.0, 2.6)),
    ConstructorOfCBpSECH(Fixed(0.002795), Fixed(2.48), Fixed(474), Fixed(8.1), Fixed(2.0), Fixed(1.3505), Fixed(0.5909), Running("w"), (-0.5, 0.5)),
    ConstructorOfPol1(Fixed(0.1), (1.0, 2.6)),
    Running("fs"),
    (1.1, 2.5)
)

model = build_model(cM_running_gw, (g = 0.115, w = 0.5, fs = 0.5,))
@test pdf(model, 1.1) ≈ 0.7084462317465321=#

using Test
include("../src/construct_model.jl")
include("../src/construct_primitives.jl")
include("../src/load_model_from_json.jl")

constructor, pars = load_prb_model_from_json("../data/database_test.json", "flatte", "CBpSECH", "Pol1")
model = build_model(constructor, pars)
pdf(model, 1.1)

#=@testset "Automatic model test" begin
    model = build_model(constructor, pars)
    @test model isa Distribution
end=#