# Physical models

## Breit-Wigner

struct ConstructorOfBW{T1<:AbstractParameter,T2<:AbstractParameter}
	description_of_m::T1
	description_of_Γ::T2
	support::Tuple{Float64,Float64}
end

function build_model(c::ConstructorOfBW, pars)
	m = value(c.description_of_m; pars)
	Γ = value(c.description_of_Γ; pars)
	NumericallyIntegrable(e->1/abs2(m^2-e^2 - 1im*m*Γ), c.support) # support needs to be larger than fit range to avoid truncation effects
end



function deserialize(::Type{<:ConstructorOfBW}, all_fields)
    appendix = NamedTuple()
    # 
    description_of_m_dict = all_fields["description_of_m"]
    type_m = _type_from_string(description_of_m_dict["type"])
    description_of_m, appendix_m = deserialize(type_m, description_of_m_dict)
    appendix = merge(appendix, appendix_m)
    # 
    description_of_Γ_dict = all_fields["description_of_Γ"]
    type_Γ = _type_from_string(description_of_Γ_dict["type"])
    description_of_Γ, appendix_Γ = deserialize(type_Γ, description_of_Γ_dict)
    appendix = merge(appendix, appendix_Γ)
    # 
    support = all_fields["support"] |> Tuple
    return ConstructorOfBW(description_of_m, description_of_Γ, support), appendix
end



serialize(c::ConstructorOfBW; pars) = LittleDict(
    "type" => "ConstructorOfBW",
    "description_of_m" => serialize(c.description_of_m; pars),
    "description_of_Γ" => serialize(c.description_of_Γ; pars),
    "support" => c.support)


## Flatte model

# using X3872Flatte: AJψππ, FlatteModel

# struct ConstructorOfFlatte{T1<:AbstractParameter,T2<:AbstractParameter,T3<:AbstractParameter}
# 	description_of_Ef::T1
#     description_of_g::T2
# 	description_of_Γ0::T3
# 	support::Tuple{Float64,Float64}
# end

# function build_model(c::ConstructorOfFlatte, pars)
# 	Ef = value(c.description_of_Ef; pars)
# 	g = value(c.description_of_g; pars)
# 	Γ0 = value(c.description_of_Γ0; pars)
# 	NumericallyIntegrable(e->abs2(AJψππ(FlatteModel(Ef, g, Γ0, 0.0, 0.0),e)), c.support) # support needs to be larger than fit range to avoid truncation effects
# end



# function deserialize(::Type{<:ConstructorOfFlatte}, all_fields)
#     appendix = NamedTuple()
#     # 
#     description_of_Ef_dict = all_fields["description_of_Ef"]
#     type_Ef = description_of_Ef_dict["type"] |> Meta.parse |> eval
#     description_of_Ef, appendix_Ef = deserialize(type_Ef, description_of_Ef_dict)
#     appendix = merge(appendix, appendix_Ef)
#     # 
#     description_of_g_dict = all_fields["description_of_g"]
#     type_g = description_of_g_dict["type"] |> Meta.parse |> eval
#     description_of_g, appendix_g = deserialize(type_g, description_of_g_dict)
#     appendix = merge(appendix, appendix_g)
#     # 
#     description_of_Γ0_dict = all_fields["description_of_Γ0"]
#     type_Γ0 = description_of_Γ0_dict["type"] |> Meta.parse |> eval
#     description_of_Γ0, appendix_Γ0 = deserialize(type_Γ0, description_of_Γ0_dict)
#     appendix = merge(appendix, appendix_Γ0)
#     # 
#     support = all_fields["support"] |> Tuple
#     return ConstructorOfFlatte(description_of_Ef, description_of_g, description_of_Γ0, support), appendix
# end



# serialize(c::ConstructorOfFlatte; pars) = LittleDict(
#     "type" => "ConstructorOfFlatte",
#     "description_of_Ef" => serialize(c.description_of_Ef; pars),
#     "description_of_g" => serialize(c.description_of_g; pars),
#     "description_of_Γ0" => serialize(c.description_of_Γ0; pars),
#     "support" => c.support)


## Braaten model

struct ConstructorOfBraaten{T1<:AbstractParameter,T2<:AbstractParameter}
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

function deserialize(::Type{<:ConstructorOfBraaten}, all_fields)
    appendix = NamedTuple()
    # 
    description_of_γre_dict = all_fields["description_of_γre"]
    type_γre = _type_from_string(description_of_γre_dict["type"])
    description_of_γre, appendix_γre = deserialize(type_γre, description_of_γre_dict)
    appendix = merge(appendix, appendix_γre)
    # 
    description_of_γim_dict = all_fields["description_of_γim"]
    type_γim = _type_from_string(description_of_γim_dict["type"])
    description_of_γim, appendix_γim = deserialize(type_γim, description_of_γim_dict)
    appendix = merge(appendix, appendix_γim)
    # 
    support = all_fields["support"] |> Tuple
    return ConstructorOfBraaten(description_of_γre, description_of_γim, support), appendix
end

serialize(c::ConstructorOfBraaten; pars) = LittleDict(
    "type" => "ConstructorOfBraaten",
    "description_of_γre" => serialize(c.description_of_γre; pars),
    "description_of_γim" => serialize(c.description_of_γim; pars),
    "support" => c.support)


# Resolution

## Crystal_Ball plus Hyperbolic_Secant

struct ConstructorOfCBpSECH{T1<:AbstractParameter,T2<:AbstractParameter,T3<:AbstractParameter,T4<:AbstractParameter,T5<:AbstractParameter,T6<:AbstractParameter,T7<:AbstractParameter,T8<:AbstractParameter}
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

function deserialize(::Type{<:ConstructorOfCBpSECH}, all_fields)
    appendix = NamedTuple()
    # 
    description_of_σ1_dict = all_fields["description_of_σ1"]
    type_σ1 = _type_from_string(description_of_σ1_dict["type"])
    description_of_σ1, appendix_σ1 = deserialize(type_σ1, description_of_σ1_dict)
    appendix = merge(appendix, appendix_σ1)
    # 
    description_of_c0_dict = all_fields["description_of_c0"]
    type_c0 = _type_from_string(description_of_c0_dict["type"])
    description_of_c0, appendix_c0 = deserialize(type_c0, description_of_c0_dict)
    appendix = merge(appendix, appendix_c0)
    # 
    description_of_c1_dict = all_fields["description_of_c1"]
    type_c1 = _type_from_string(description_of_c1_dict["type"])
    description_of_c1, appendix_c1 = deserialize(type_c1, description_of_c1_dict)
    appendix = merge(appendix, appendix_c1)
    # 
    description_of_c2_dict = all_fields["description_of_c2"]
    type_c2 = _type_from_string(description_of_c2_dict["type"])
    description_of_c2, appendix_c2 = deserialize(type_c2, description_of_c2_dict)
    appendix = merge(appendix, appendix_c2)
    # 
    description_of_n_dict = all_fields["description_of_n"]
    type_n = _type_from_string(description_of_n_dict["type"])
    description_of_n, appendix_n = deserialize(type_n, description_of_n_dict)
    appendix = merge(appendix, appendix_n)
    # 
    description_of_s_dict = all_fields["description_of_s"]
    type_s = _type_from_string(description_of_s_dict["type"])
    description_of_s, appendix_s = deserialize(type_s, description_of_s_dict)
    appendix = merge(appendix, appendix_s)
    # 
    description_of_fr1_dict = all_fields["description_of_fr1"]
    type_fr1 = _type_from_string(description_of_fr1_dict["type"])
    description_of_fr1, appendix_fr1 = deserialize(type_fr1, description_of_fr1_dict)
    appendix = merge(appendix, appendix_fr1)
    # 
    description_of_w_dict = all_fields["description_of_w"]
    type_w = _type_from_string(description_of_w_dict["type"])
    description_of_w, appendix_w = deserialize(type_w, description_of_w_dict)
    appendix = merge(appendix, appendix_w)
    # 
    support = all_fields["support"] |> Tuple
    return ConstructorOfCBpSECH(description_of_σ1, description_of_c0, description_of_c1, description_of_c2, description_of_n, description_of_s, description_of_fr1, description_of_w, support), appendix
end

serialize(c::ConstructorOfCBpSECH; pars) = LittleDict(
    "type" => "ConstructorOfCBpSECH",
    "description_of_σ1" => serialize(c.description_of_σ1; pars),
    "description_of_c0" => serialize(c.description_of_c0; pars),
    "description_of_c1" => serialize(c.description_of_c1; pars),
    "description_of_c2" => serialize(c.description_of_c2; pars),
    "description_of_n" => serialize(c.description_of_n; pars),
    "description_of_s" => serialize(c.description_of_s; pars),
    "description_of_fr1" => serialize(c.description_of_fr1; pars),
    "description_of_w" => serialize(c.description_of_w; pars),
    "support" => c.support)

## Gaussian

struct ConstructorOfGaussian{T1<:AbstractParameter,T2<:AbstractParameter}
    description_of_μ::T1
    description_of_σ::T2
    support::Tuple{Float64,Float64}
end

function build_model(c::ConstructorOfGaussian, pars)
    μ = value(c.description_of_μ; pars)
    σ = value(c.description_of_σ; pars)
    truncated(Normal(μ, σ), c.support[1], c.support[2])
end

function deserialize(::Type{<:ConstructorOfGaussian}, all_fields)
    appendix = NamedTuple()
    # 
    description_of_μ_dict = all_fields["description_of_μ"]
    type_μ = _type_from_string(description_of_μ_dict["type"])
    description_of_μ, appendix_μ = deserialize(type_μ, description_of_μ_dict)
    appendix = merge(appendix, appendix_μ)
    # 
    description_of_σ_dict = all_fields["description_of_σ"]
    type_σ = _type_from_string(description_of_σ_dict["type"])
    description_of_σ, appendix_σ = deserialize(type_σ, description_of_σ_dict)
    appendix = merge(appendix, appendix_σ)
    # 
    support = all_fields["support"] |> Tuple
    return ConstructorOfGaussian(description_of_μ, description_of_σ, support), appendix
end

serialize(c::ConstructorOfGaussian; pars) = LittleDict(
    "type" => "ConstructorOfGaussian",
    "description_of_μ" => serialize(c.description_of_μ; pars),
    "description_of_σ" => serialize(c.description_of_σ; pars),
    "support" => c.support)

# Background

## 1st order Chebyshev

struct ConstructorOfPol1{T}
    description_of_c1C::T
    support::Tuple{Float64,Float64}
end

function build_model(c::ConstructorOfPol1, pars)
    c1C = value(c.description_of_c1C; pars)
    Chebyshev([1, c1C], c.support[1], c.support[2])
end

function deserialize(::Type{<:ConstructorOfPol1}, all_fields)
    appendix = NamedTuple()
    # 
    description_of_c1C_dict = all_fields["description_of_c1C"]
    type_c1C = _type_from_string(description_of_c1C_dict["type"])
    description_of_c1C, appendix_c1C = deserialize(type_c1C, description_of_c1C_dict)
    appendix = merge(appendix, appendix_c1C)
    # 
    support = all_fields["support"] |> Tuple
    return ConstructorOfPol1(description_of_c1C, support), appendix
end

serialize(c::ConstructorOfPol1; pars) = LittleDict(
    "type" => "ConstructorOfPol1",
    "description_of_c1C" => serialize(c.description_of_c1C; pars),
    "support" => c.support)

## 2nd order Chebyshev

struct ConstructorOfPol2{T}
    description_of_c1C::T
    description_of_c2C::T
    support::Tuple{Float64,Float64}
end

function build_model(c::ConstructorOfPol2, pars)
    c1C = value(c.description_of_c1C; pars)
    c2C = value(c.description_of_c2C; pars)
    Chebyshev([1, c1C, c2C], c.support[1], c.support[2])
end

function deserialize(::Type{<:ConstructorOfPol2}, all_fields)
    appendix = NamedTuple()
    # 
    description_of_c1C_dict = all_fields["description_of_c1C"]
    type_c1C = _type_from_string(description_of_c1C_dict["type"])
    description_of_c1C, appendix_c1C = deserialize(type_c1C, description_of_c1C_dict)
    appendix = merge(appendix, appendix_c1C)
    # 
    description_of_c2C_dict = all_fields["description_of_c2C"]
    type_c2C = _type_from_string(description_of_c2C_dict["type"])
    description_of_c2C, appendix_c2C = deserialize(type_c2C, description_of_c2C_dict)
    appendix = merge(appendix, appendix_c2C)
    # 
    support = all_fields["support"] |> Tuple
    return ConstructorOfPol2(description_of_c1C, description_of_c2C, support), appendix
end

serialize(c::ConstructorOfPol2; pars) = LittleDict(
    "type" => "ConstructorOfPol2",
    "description_of_c1C" => serialize(c.description_of_c1C; pars),
    "description_of_c2C" => serialize(c.description_of_c2C; pars),
    "support" => c.support)

# Auto-register built-in constructor types
register_type("ConstructorOfBW", ConstructorOfBW)
register_type("ConstructorOfBraaten", ConstructorOfBraaten)
register_type("ConstructorOfCBpSECH", ConstructorOfCBpSECH)
register_type("ConstructorOfGaussian", ConstructorOfGaussian)
register_type("ConstructorOfPol1", ConstructorOfPol1)
register_type("ConstructorOfPol2", ConstructorOfPol2)