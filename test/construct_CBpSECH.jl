using Distributions
using NumericalDistributions
using DistributionsHEP
using OrderedCollections



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
    type_σ1 = description_of_σ1_dict["type"] |> Meta.parse |> eval
    description_of_σ1, appendix_σ1 = deserialize(type_σ1, description_of_σ1_dict)
    appendix = merge(appendix, appendix_σ1)
    # 
    description_of_c0_dict = all_fields["description_of_c0"]
    type_c0 = description_of_c0_dict["type"] |> Meta.parse |> eval
    description_of_c0, appendix_c0 = deserialize(type_c0, description_of_c0_dict)
    appendix = merge(appendix, appendix_c0)
    # 
    description_of_c1_dict = all_fields["description_of_c1"]
    type_c1 = description_of_c1_dict["type"] |> Meta.parse |> eval
    description_of_c1, appendix_c1 = deserialize(type_c1, description_of_c1_dict)
    appendix = merge(appendix, appendix_c1)
    # 
    description_of_c2_dict = all_fields["description_of_c2"]
    type_c2 = description_of_c2_dict["type"] |> Meta.parse |> eval
    description_of_c2, appendix_c2 = deserialize(type_c2, description_of_c2_dict)
    appendix = merge(appendix, appendix_c2)
    # 
    description_of_n_dict = all_fields["description_of_n"]
    type_n = description_of_n_dict["type"] |> Meta.parse |> eval
    description_of_n, appendix_n = deserialize(type_n, description_of_n_dict)
    appendix = merge(appendix, appendix_n)
    # 
    description_of_s_dict = all_fields["description_of_s"]
    type_s = description_of_s_dict["type"] |> Meta.parse |> eval
    description_of_s, appendix_s = deserialize(type_s, description_of_s_dict)
    appendix = merge(appendix, appendix_s)
    # 
    description_of_fr1_dict = all_fields["description_of_fr1"]
    type_fr1 = description_of_fr1_dict["type"] |> Meta.parse |> eval
    description_of_fr1, appendix_fr1 = deserialize(type_fr1, description_of_fr1_dict)
    appendix = merge(appendix, appendix_fr1)
    # 
    description_of_w_dict = all_fields["description_of_w"]
    type_w = description_of_w_dict["type"] |> Meta.parse |> eval
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