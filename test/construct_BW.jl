using Distributions
using NumericalDistributions
using DistributionsHEP
using OrderedCollections



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
    type_m = description_of_m_dict["type"] |> Meta.parse |> eval
    description_of_m, appendix_m = deserialize(type_m, description_of_m_dict)
    appendix = merge(appendix, appendix_m)
    # 
    description_of_Γ_dict = all_fields["description_of_Γ"]
    type_Γ = description_of_Γ_dict["type"] |> Meta.parse |> eval
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