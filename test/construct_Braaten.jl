using Distributions
using NumericalDistributions
using DistributionsHEP
using OrderedCollections



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
    type_γre = description_of_γre_dict["type"] |> Meta.parse |> eval
    description_of_γre, appendix_γre = deserialize(type_γre, description_of_γre_dict)
    appendix = merge(appendix, appendix_γre)
    # 
    description_of_γim_dict = all_fields["description_of_γim"]
    type_γim = description_of_γim_dict["type"] |> Meta.parse |> eval
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