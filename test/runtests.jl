using Test


include("construct_model.jl")
include("construct_primitives.jl")


cM_running_gw = ConstructorOfPRBModel(
    ConstructorOfFlatte(Fixed(-7.66), Running("g"), Fixed(1.88), (1.0, 2.6)),
    ConstructorOfCBpSECH(Fixed(0.002795), Fixed(2.48), Fixed(474), Fixed(8.1), Fixed(2.0), Fixed(1.3505), Fixed(0.5909), Running("w"), (-0.5, 0.5)),
    ConstructorOfPol1(Fixed(0.1), (1.0, 2.6)),
    Fixed(0.5),
    (1.1, 2.5)
)

model = build_model(cM_running_gw, (g = 0.115, w = 0.5,))
@test pdf(model, 1.1) ≈ 0.7084462317465321