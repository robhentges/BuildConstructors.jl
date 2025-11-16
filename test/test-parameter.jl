using BuildConstructors
using ComponentArrays
using Test

constructor = ConstructorOfPRBModel(
    ConstructorOfBW(Parameter("m", 2.0), Parameter("Γ", 0.2), (1.0, 2.5)),
    ConstructorOfGaussian(Fixed(0.0), Parameter("σ", 0.1), (-0.5, 0.5)),
    ConstructorOfPol1(Parameter("c1", 0.3), (1.0, 2.5)),
    Parameter("fs", 0.5),
    (1.0, 2.5),
)

@testset "Parameter is mutable" begin
    @test constructor.model_p.description_of_m.fixed == false
    setfield!(constructor.model_p.description_of_m, :fixed, true)
    @test getfield(constructor.model_p.description_of_m, :fixed) == true
    setfield!(constructor.model_p.description_of_m, :fixed, false)
    @test getfield(constructor.model_p.description_of_m, :fixed) == false
end


# tests
@testset "fix and release, one argument" begin
    fix!(constructor.model_p, (:m,))
    @test constructor.model_p.description_of_m.fixed == true
    release!(constructor.model_p, (:m,))
    @test constructor.model_p.description_of_m.fixed == false
end

@testset "fix and release, few argument" begin
    fix!(constructor, (:m, :Γ, :c1))
    @test constructor.model_p.description_of_m.fixed == true
    @test constructor.model_p.description_of_Γ.fixed == true
    @test constructor.model_b.description_of_c1C.fixed == true
    release!(constructor, (:m, :Γ, :c1))
    @test constructor.model_p.description_of_m.fixed == false
    @test constructor.model_p.description_of_Γ.fixed == false
    @test constructor.model_b.description_of_c1C.fixed == false
end

@testset "Fix and release works with array" begin
    fix!(constructor, [:m, :Γ, :c1])
    @test constructor.model_p.description_of_m.fixed == true
    @test constructor.model_p.description_of_Γ.fixed == true
    @test constructor.model_b.description_of_c1C.fixed == true
    release!(constructor, [:m, :Γ, :c1])
    @test constructor.model_p.description_of_m.fixed == false
    @test constructor.model_p.description_of_Γ.fixed == false
    @test constructor.model_b.description_of_c1C.fixed == false
end

@testset "Update and pickup" begin
    @test pickup(constructor.model_p) == (m = 2.0, Γ = 0.2)
    update!(constructor.model_p, (m = 1.9, Γ = 0.1))
    @test pickup(constructor.model_p) == (m = 1.9, Γ = 0.1)
    @test pickup(constructor) |> keys == (:m, :Γ, :σ, :c1, :fs)
    update!(constructor.model_p, (m = 2.0, Γ = 0.2))
end

@testset "Update works with ComponentArray" begin
    @test pickup(constructor.model_p) == (m = 2.0, Γ = 0.2)
    update!(constructor.model_p, ComponentArray(m = 1.9, Γ = 0.1))
    @test pickup(constructor.model_p) == (m = 1.9, Γ = 0.1)
    update!(constructor.model_p, (m = 2.0, Γ = 0.2))
end

@testset "Release all, and fix all" begin
    release!(constructor)
    @test constructor.model_p.description_of_m.fixed == false
    @test constructor.model_p.description_of_Γ.fixed == false
    @test constructor.model_r.description_of_σ.fixed == false
    @test constructor.model_b.description_of_c1C.fixed == false
    @test constructor.description_of_fs.fixed == false
    fix!(constructor)
    @test constructor.model_p.description_of_m.fixed == true
    @test constructor.model_p.description_of_Γ.fixed == true
    @test constructor.model_r.description_of_σ.fixed == true
    @test constructor.model_b.description_of_c1C.fixed == true
    @test constructor.description_of_fs.fixed == true
end
