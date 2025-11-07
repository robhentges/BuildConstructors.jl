using Distributions
using NumericalDistributions
using DistributionsHEP
using OrderedCollections



struct ConstructorOfPol1{T}
	description_of_c1::T
	support::Tuple{Float64,Float64}
end

function build_model(c::ConstructorOfPol1, pars)
	c1 = value(c.description_of_c1; pars)
	Chebyshev([1, c1], c.support[1], c.support[2])
end



function deserialize(::Type{<:ConstructorOfPol1}, all_fields)
    appendix = NamedTuple()
    # 
    description_of_c1_dict = all_fields["description_of_c1"]
    type_c1 = description_of_c1_dict["type"] |> Meta.parse |> eval
    description_of_c1, appendix_c1 = deserialize(type_c1, description_of_c1_dict)
    appendix = merge(appendix, appendix_c1)
    # 
    support = all_fields["support"] |> Tuple
    return ConstructorOfPol1(description_of_c1, support), appendix
end



serialize(c::ConstructorOfPol1; pars) = LittleDict(
    "type" => "ConstructorOfPol1",
    "description_of_c1" => serialize(c.description_of_c1; pars),
    "support" => c.support)