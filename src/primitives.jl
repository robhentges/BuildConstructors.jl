struct ConstructorOfBW
	name_of_m::String
	name_of_Γ::String
	support::Tuple{Float64,Float64}
end

function build_model(c::ConstructorOfBW, pars)
	m = getproperty(pars, Symbol(c.name_of_m))
	Γ = getproperty(pars, Symbol(c.name_of_Γ))
	NumericallyIntegrable(e->1/abs2(m^2-e^2 - 1im*m*Γ), c.support)
end





struct ConstructorOfGaussian{T}
	name_of_μ::T
	name_of_σ::String
	support::Tuple{Float64,Float64}
end

ConstructorOfZeroGaussian(name_of_σ, support) = ConstructorOfGaussian(0, name_of_σ, support)

function build_model(c::ConstructorOfGaussian{String}, pars)
	μ = getproperty(pars, Symbol(c.name_of_μ))
	σ = getproperty(pars, Symbol(c.name_of_σ))
	truncated(Normal(μ, σ), c.support[1], c.support[2])
end

# special case when mu is fixed
function build_model(c::ConstructorOfGaussian{<:Number}, pars)
	μ = c.name_of_μ
	σ = getproperty(pars, Symbol(c.name_of_σ))
	truncated(Normal(μ, σ), c.support[1], c.support[2])
end







struct ConstructorOfPol1
	name_of_c1::String
	support::Tuple{Float64,Float64}
end

function build_model(c::ConstructorOfPol1, pars)
	c1 = getproperty(pars, Symbol(c.name_of_c1))
	Chebyshev([1, c1], c.support[1], c.support[2])
end
