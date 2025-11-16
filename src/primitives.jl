struct ConstructorOfBW{T1<:AbstractParameter,T2<:AbstractParameter} <: AbstractConstructor
    description_of_m::T1
    description_of_Γ::T2
    support::Tuple{Float64,Float64}
end

function build_model(c::ConstructorOfBW, pars)
    m = value(c.description_of_m; pars)
    Γ = value(c.description_of_Γ; pars)
    NumericallyIntegrable(e->1/abs2(m^2-e^2 - 1im*m*Γ), c.support) # support needs to be larger than fit range to avoid truncation effects
end


struct ConstructorOfBraaten{T1<:AbstractParameter,T2<:AbstractParameter} <:
       AbstractConstructor
    description_of_γre::T1
    description_of_γim::T2
    support::Tuple{Float64,Float64}
end

function build_model(c::ConstructorOfBraaten, pars)
    γre = value(c.description_of_γre; pars)
    γim = value(c.description_of_γim; pars)
    μ = 0.9666176144464419 # reduced mass of D0 and D*0 in GeV/c^2
    k1(E::Complex) = 1im * sqrt(-2μ * (E * 1e-3))
    k1(E::Real) = k1(E + 1e-7im)
    NumericallyIntegrable(e->1/abs2(-γre-1im*γim-1im*k1(e)), c.support) # support needs to be larger than fit range to avoid truncation effects
end



# Resolution

## Crystal_Ball plus Hyperbolic_Secant

struct ConstructorOfCBpSECH{
    T1<:AbstractParameter,
    T2<:AbstractParameter,
    T3<:AbstractParameter,
    T4<:AbstractParameter,
    T5<:AbstractParameter,
    T6<:AbstractParameter,
    T7<:AbstractParameter,
    T8<:AbstractParameter,
} <: AbstractConstructor
    description_of_σ1::T1
    description_of_c0::T2
    description_of_c1::T3
    description_of_c2::T4
    description_of_n::T5
    description_of_s::T6
    description_of_fr1::T7
    description_of_w::T8
    support::Tuple{Float64,Float64}
end

function build_model(c::ConstructorOfCBpSECH, pars)
    σ1 = value(c.description_of_σ1; pars)
    c0 = value(c.description_of_c0; pars)
    c1 = value(c.description_of_c1; pars)
    c2 = value(c.description_of_c2; pars)
    n = value(c.description_of_n; pars)
    s = value(c.description_of_s; pars)
    fr1 = value(c.description_of_fr1; pars)
    w = value(c.description_of_w; pars)
    σ2 = s * σ1
    σ1_MeV, σ2_MeV = (σ1, σ2) .* 1e3
    α = c0 * (c1 * σ1)^c2 / (1 + (c1 * σ1)^c2)
    d1 = CrystalBall(0.0, σ1_MeV, α, n)
    hyp_sec(x, μ, σ) = 1/(2*σ)*sech(π/2 * (x-μ)/σ)
    d2 = NumericallyIntegrable(x->hyp_sec(x, 0.0, σ2_MeV), (c.support[1], c.support[2]))
    # 
    td1 = truncated(d1, c.support[1], c.support[2])
    td2 = truncated(d2, c.support[1], c.support[2])
    # mixture model
    w*MixtureModel([td1, td2], [fr1, 1-fr1])
end

## Gaussian

struct ConstructorOfGaussian{T1<:AbstractParameter,T2<:AbstractParameter} <:
       AbstractConstructor
    description_of_μ::T1
    description_of_σ::T2
    support::Tuple{Float64,Float64}
end

function build_model(c::ConstructorOfGaussian, pars)
    μ = value(c.description_of_μ; pars)
    σ = value(c.description_of_σ; pars)
    truncated(Normal(μ, σ), c.support[1], c.support[2])
end


# Background

## 1st order Chebyshev

struct ConstructorOfPol1{T} <: AbstractConstructor
    description_of_c1C::T
    support::Tuple{Float64,Float64}
end

function build_model(c::ConstructorOfPol1, pars)
    c1C = value(c.description_of_c1C; pars)
    Chebyshev([1, c1C], c.support[1], c.support[2])
end


## 2nd order Chebyshev

struct ConstructorOfPol2{T} <: AbstractConstructor
    description_of_c1C::T
    description_of_c2C::T
    support::Tuple{Float64,Float64}
end

function build_model(c::ConstructorOfPol2, pars)
    c1C = value(c.description_of_c1C; pars)
    c2C = value(c.description_of_c2C; pars)
    Chebyshev([1, c1C, c2C], c.support[1], c.support[2])
end
