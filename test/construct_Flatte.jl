using Distributions
using NumericalDistributions
using DistributionsHEP
using OrderedCollections
using X3872EffRange
using X3872Flatte



struct ConstructorOfFlatte{T1<:AbstractParameter,T2<:AbstractParameter,T3<:AbstractParameter}
	description_of_Ef::T1
    description_of_g::T2
	description_of_Γ0::T3
	support::Tuple{Float64,Float64}
end

function build_model(c::ConstructorOfFlatte, pars)
	Ef = value(c.description_of_Ef; pars)
	g = value(c.description_of_g; pars)
	Γ0 = value(c.description_of_Γ0; pars)
	NumericallyIntegrable(e->abs2(AJψππ(FlatteModel(Ef, g, Γ0, 0.0, 0.0),e)), c.support) # support needs to be larger than fit range to avoid truncation effects
end



function deserialize(::Type{<:ConstructorOfFlatte}, all_fields)
    appendix = NamedTuple()
    # 
    description_of_Ef_dict = all_fields["description_of_Ef"]
    type_Ef = description_of_Ef_dict["type"] |> Meta.parse |> eval
    description_of_Ef, appendix_Ef = deserialize(type_Ef, description_of_Ef_dict)
    appendix = merge(appendix, appendix_Ef)
    # 
    description_of_g_dict = all_fields["description_of_g"]
    type_g = description_of_g_dict["type"] |> Meta.parse |> eval
    description_of_g, appendix_g = deserialize(type_g, description_of_g_dict)
    appendix = merge(appendix, appendix_g)
    # 
    description_of_Γ0_dict = all_fields["description_of_Γ0"]
    type_Γ0 = description_of_Γ0_dict["type"] |> Meta.parse |> eval
    description_of_Γ0, appendix_Γ0 = deserialize(type_Γ0, description_of_Γ0_dict)
    appendix = merge(appendix, appendix_Γ0)
    # 
    support = all_fields["support"] |> Tuple
    return ConstructorOfFlatte(description_of_Ef, description_of_g, description_of_Γ0, support), appendix
end



serialize(c::ConstructorOfFlatte; pars) = LittleDict(
    "type" => "ConstructorOfFlatte",
    "description_of_Ef" => serialize(c.description_of_Ef; pars),
    "description_of_g" => serialize(c.description_of_g; pars),
    "description_of_Γ0" => serialize(c.description_of_Γ0; pars),
    "support" => c.support)