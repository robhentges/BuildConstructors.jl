using DistributionsHEP  # For Chebyshev
using BuildConstructors
using Distributions
using Test

# Import types and functions needed for macro expansion
import BuildConstructors: AbstractParameter, AbstractConstructor, value, build_model

# Test Case 1: Simple 2-parameter model (Gaussian)
# This should generate the same as the manual ConstructorOfGaussian
@with_parameters(GaussianMacro, μ, σ; support::Tuple{Float64,Float64}, begin
    truncated(Normal(μ, σ), _.support[1], _.support[2])
end)

# Test instantiation
cg_macro = ConstructorOfGaussianMacro(Fixed(0.0), Running("σ"), (-0.5, 0.5))
cg_manual = ConstructorOfGaussian(Fixed(0.0), Running("σ"), (-0.5, 0.5))

@testset "Macro-generated Gaussian" begin
    # Test that struct was generated correctly
    @test cg_macro.description_of_μ isa Fixed
    @test cg_macro.description_of_σ isa Running
    @test cg_macro.support == (-0.5, 0.5)
    
    # Test build_model functionality
    pars = (σ = 0.1,)
    model_macro = build_model(cg_macro, pars)
    model_manual = build_model(cg_manual, pars)
    
    # Test that models produce same results
    @test pdf(model_macro, 0.0) ≈ pdf(model_manual, 0.0)
    @test pdf(model_macro, 0.1) ≈ pdf(model_manual, 0.1)
    @test pdf(model_macro, -0.1) ≈ pdf(model_manual, -0.1)
    
    # Test with all fixed parameters
    cg_macro_fixed = ConstructorOfGaussianMacro(Fixed(0.0), Fixed(0.1), (-0.5, 0.5))
    cg_manual_fixed = ConstructorOfGaussian(Fixed(0.0), Fixed(0.1), (-0.5, 0.5))
    model_macro_fixed = build_model(cg_macro_fixed, NamedTuple())
    model_manual_fixed = build_model(cg_manual_fixed, NamedTuple())
    @test pdf(model_macro_fixed, 0.0) ≈ pdf(model_manual_fixed, 0.0)
end

# Test Case 2: 1-parameter model (Pol1)
@with_parameters(Pol1Macro, c1C; support::Tuple{Float64,Float64}, begin
    Chebyshev([1, c1C], _.support[1], _.support[2])
end)

cp1_macro = ConstructorOfPol1Macro(Running("c1C"), (1.1, 2.5))
cp1_manual = ConstructorOfPol1(Running("c1C"), (1.1, 2.5))

@testset "Macro-generated Pol1" begin
    pars = (c1C = 0.01,)
    model_macro = build_model(cp1_macro, pars)
    model_manual = build_model(cp1_manual, pars)
    
    @test pdf(model_macro, 1.5) ≈ pdf(model_manual, 1.5)
end

# Test Case 3: Complex parameter names (no support field needed)
@with_parameters(TestModelMacro, γre, γim, begin
    # Simple test - just return a number for now
    γre + γim
end)

ctm = ConstructorOfTestModelMacro(Fixed(1.0), Fixed(2.0))

@testset "Macro with complex parameter names" begin
    @test ctm.description_of_γre isa Fixed
    @test ctm.description_of_γim isa Fixed
    result = build_model(ctm, NamedTuple())
    @test result == 3.0
end

# Test Case 4: Multiple constant fields
@with_parameters(ComplexModel, μ, σ; support::Tuple{Float64,Float64}, threshold::Float64, n_bins::Int, begin
    # Use multiple constant fields
    if μ > _.threshold
        truncated(Normal(μ, σ), _.support[1], _.support[2])
    else
        # Use n_bins for something
        Normal(μ, σ)
    end
end)

cm = ConstructorOfComplexModel(Fixed(0.0), Fixed(0.1), (-0.5, 0.5), 0.0, 10)

@testset "Macro with multiple constant fields" begin
    @test cm.support == (-0.5, 0.5)
    @test cm.threshold == 0.0
    @test cm.n_bins == 10
    model = build_model(cm, NamedTuple())
    @test model isa Distribution
end

println("All macro tests passed!")

