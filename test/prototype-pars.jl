using Distributions
using NumericalDistributions
using DistributionsHEP
using OrderedCollections
using X3872EffRange
using X3872Flatte


abstract type AbstractParameter end

struct Fixed <: AbstractParameter
    value::Float64
end

struct Running <: AbstractParameter
    name::String
end

value(p::Fixed; pars) = p.value
value(p::Running; pars) = getproperty(pars, Symbol(p.name))




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


using Test

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

cCBpSECH_running_w = ConstructorOfCBpSECH(Fixed(0.002795), Fixed(2.48), Fixed(474), Fixed(8.1), Fixed(2.0), Fixed(1.3505), Fixed(0.5909), Running("w"), (1.1, 2.5))
model = build_model(cCBpSECH_running_w, (w = 0.5,))
#@test pdf(model, 1.1) == 110.89465029715275

cG_fixed_μ = ConstructorOfGaussian(Fixed(0), Running("σ"), (1.1, 2.5))
model = build_model(cG_fixed_μ, (σ = 0.1,))
@test pdf(model, 1.1) == 110.89465029715275


cG_running_μ = ConstructorOfGaussian(Running("μ"), Running("σ"), (1.1, 2.5))
model = build_model(cG_running_μ, (μ = 0.0, σ = 0.1,))
@test pdf(model, 1.1) == 110.89465029715275

cG_fixed_μσ = ConstructorOfGaussian(Fixed(0), Fixed(0.1), (1.1, 2.5))
model = build_model(cG_fixed_μσ, NamedTuple())
@test pdf(model, 1.1) == 110.89465029715275






struct ConstructorOfPol1{T}
	description_of_c1::T
	support::Tuple{Float64,Float64}
end

function build_model(c::ConstructorOfPol1, pars)
	c1 = value(c.description_of_c1; pars)
	Chebyshev([1, c1], c.support[1], c.support[2])
end



struct ConstructorOfPRBModel{PHYS,RES,BG,T}
	model_p::PHYS
	model_r::RES
	model_b::BG
	description_of_fs::T
    support::Tuple{Float64,Float64} # not same as model support, rather actual fit range
end

function build_model(c::ConstructorOfPRBModel, pars)
	p = build_model(c.model_p, pars)
	r = build_model(c.model_r, pars)
	b = build_model(c.model_b, pars)
	r_conv_p = fft_convolve(r, p)
	fs = value(c.description_of_fs; pars)
	truncated(MixtureModel([r_conv_p, b], [fs, 1-fs]), c.support[1], c.support[2])
end

cM_running_w = ConstructorOfPRBModel(
    ConstructorOfFlatte(Fixed(-7.66), Fixed(0.115), Fixed(1.88), (1.0, 2.6)),
    ConstructorOfCBpSECH(Fixed(0.002795), Fixed(2.48), Fixed(474), Fixed(8.1), Fixed(2.0), Fixed(1.3505), Fixed(0.5909), Running("w"), (-0.5, 0.5)),
    ConstructorOfPol1(Fixed(0.1), (1.0, 2.6)),
    Fixed(0.5),
    (1.1, 2.5)
)

using X3872Flatte: AJψππ, FlatteModel

model = build_model(cM_running_w, (w = 0.5,))
@test pdf(model, 1.1) ≈ 0.7084462317465321




struct ConstructorOfTwoComponentModel{C1,C2,T}
	model_c1::C1
	model_c2::C2
	description_of_fs1::T
end


function build_model(c::ConstructorOfTwoComponentModel, pars)
	c1 = build_model(c.model_c1, pars)
	c2  = build_model(c.model_c2, pars)
	fs1 = value(c.description_of_fs1; pars)
	MixtureModel([c1, c2], [fs1, 1-fs1])
end


serialize(c::ConstructorOfTwoComponentModel; pars) = LittleDict(
    "type" => "ConstructorOfTwoComponentModel",
    "model_c1" => serialize(c.model_c1; pars),
    "model_c2" => serialize(c.model_c2; pars),
    "description_of_fs1" => serialize(c.description_of_fs1; pars))

function deserialize(::Type{<:ConstructorOfTwoComponentModel}, all_fields)
    appendix = NamedTuple()
    # 
    model_c1_dict = all_fields["model_c1"]
    type_c1 = model_c1_dict["type"] |> Meta.parse |> eval
    model_c1, appendix_c1 = deserialize(type_c1, model_c1_dict)
    appendix = merge(appendix, appendix_c1)
    # 
    model_c2_dict = all_fields["model_c2"]
    type_c2 = model_c2_dict["type"] |> Meta.parse |> eval
    model_c2, appendix_c2 = deserialize(type_c2, model_c2_dict)
    appendix = merge(appendix, appendix_c2)
    # 
    description_of_fs1_dict = all_fields["description_of_fs1"]
    type_fs1 = description_of_fs1_dict["type"] |> Meta.parse |> eval
    description_of_fs1, appendix_fs1 = deserialize(type_fs1, description_of_fs1_dict)
    appendix = merge(appendix, appendix_c2)
    # 
    ConstructorOfTwoComponentModel(model_c1, model_c2, description_of_fs1), appendix
end





using JSON

# naive serialization does not write type information
# 
# open("test-serialization.json", "w") do f
#     JSON.print(f, Dict(
#         "my_model" => cM_running_σ
#     ))
# end







data = open(joinpath(@__DIR__, "test-serialization.json")) do f
    JSON.parse(f)
end

data["my_model"]["model_p"]



all_fields = data["my_model"]
string_type = all_fields["type"]
evaluated_type = eval(Meta.parse(string_type))

# c, starting_pars = build_constructor(evaluated_type, all_fields)

function deserialize(::Type{<:Fixed}, all_fields)
    value = all_fields["value"]
    Fixed(value), NamedTuple()
end

function deserialize(::Type{<:Running}, all_fields)
    name = all_fields["name"]
    starting_value = all_fields["starting_value"]
    Running(name), NamedTuple{(Symbol(name),)}((starting_value,))
end




let
    c, s = deserialize(Fixed, all_fields["model_p"]["description_of_m"])
    @test s == NamedTuple()
    @test c isa Fixed
    @test c.value == 2.1
end

let
    c, s = deserialize(Running, all_fields["model_r"]["description_of_σ"])
    @test s == (σ=0.1,)
    @test c isa Running
    @test c.name == "σ"
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




let 
    c, s = deserialize(ConstructorOfBW, all_fields["model_p"])
    @test s == NamedTuple()
    @test c isa ConstructorOfBW
end


function deserialize(::Type{<:ConstructorOfFlatte}, all_fields)
    appendix = NamedTuple()
    # 
    description_of_m_dict = all_fields["description_of_Ef"]
    type_m = description_of_m_dict["type"] |> Meta.parse |> eval
    description_of_m, appendix_m = deserialize(type_m, description_of_m_dict)
    appendix = merge(appendix, appendix_m)
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
    return ConstructorOfFlatte(description_of_m, description_of_g, description_of_Γ0, support), appendix
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


function deserialize(::Type{<:ConstructorOfGaussian}, all_fields)
    appendix = NamedTuple()
    # 
    description_of_μ_dict = all_fields["description_of_μ"]
    type_μ = description_of_μ_dict["type"] |> Meta.parse |> eval
    description_of_μ, appendix_μ = deserialize(type_μ, description_of_μ_dict)
    appendix = merge(appendix, appendix_μ)
    # 
    description_of_σ_dict = all_fields["description_of_σ"]
    type_σ = description_of_σ_dict["type"] |> Meta.parse |> eval
    description_of_σ, appendix_σ = deserialize(type_σ, description_of_σ_dict)
    appendix = merge(appendix, appendix_σ)
    # 
    support = all_fields["support"] |> Tuple
    return ConstructorOfGaussian(description_of_μ, description_of_σ, support), appendix
end



let 
    c, s = deserialize(ConstructorOfGaussian, all_fields["model_r"])
    @test s == (σ=0.1,)
    @test c isa ConstructorOfGaussian
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


let 
    c, s = deserialize(ConstructorOfPol1, all_fields["model_b"])
    @test s == NamedTuple()
    @test c isa ConstructorOfPol1
end








function deserialize(::Type{<:ConstructorOfPRBModel}, all_fields)
    appendix = NamedTuple()

    
    description_of_p = all_fields["model_p"]
    type_p = description_of_p["type"] |> Meta.parse |> eval
    model_p, appendix_p = deserialize(type_p, description_of_p)
    appendix = merge(appendix, appendix_p)

    description_of_r = all_fields["model_r"]
    type_r = description_of_r["type"] |> Meta.parse |> eval
    model_r, appendix_r = deserialize(type_r, description_of_r)
    appendix = merge(appendix, appendix_r)

    description_of_b = all_fields["model_b"]
    type_b = description_of_b["type"] |> Meta.parse |> eval
    model_b, appendix_b = deserialize(type_b, description_of_b)
    appendix = merge(appendix, appendix_b)

    description_of_fs = all_fields["description_of_fs"]
    type_fs = description_of_fs["type"] |> Meta.parse |> eval
    description_of_fs, appendix_fs = deserialize(type_fs, description_of_fs)
    appendix = merge(appendix, appendix_fs)

    support = all_fields["support"] |> Tuple
    ConstructorOfPRBModel(model_p, model_r, model_b, description_of_fs, support), appendix
end


let 
    c, s = deserialize(ConstructorOfPRBModel, data["my_model"])
    @test s == (σ = 0.1,)
    @test c isa ConstructorOfPRBModel
end





#  proper serialization


serialize(c::Fixed; pars) = LittleDict("type" => "Fixed", "value" => c.value)
serialize(c::Running; pars) = LittleDict("type" => "Running", "name" => c.name, "starting_value" => value(c; pars))

serialize(c::ConstructorOfBW; pars) = LittleDict(
    "type" => "ConstructorOfBW",
    "description_of_m" => serialize(c.description_of_m; pars),
    "description_of_Γ" => serialize(c.description_of_Γ; pars),
    "support" => c.support)


serialize(c::ConstructorOfFlatte; pars) = LittleDict(
    "type" => "ConstructorOfFlatte",
    "description_of_Ef" => serialize(c.description_of_Ef; pars),
    "description_of_g" => serialize(c.description_of_g; pars),
    "description_of_Γ0" => serialize(c.description_of_Γ0; pars),
    "support" => c.support)

serialize(c::ConstructorOfBraaten; pars) = LittleDict(
    "type" => "ConstructorOfBraaten",
    "description_of_γre" => serialize(c.description_of_γre; pars),
    "description_of_γim" => serialize(c.description_of_γim; pars),
    "support" => c.support)

# test here
# serialize(cM_running_σ.model_p; pars = (σ = 0.1,))

serialize(c::ConstructorOfGaussian; pars) = LittleDict(
    "type" => "ConstructorOfGaussian",
    "description_of_μ" => serialize(c.description_of_μ; pars),
    "description_of_σ" => serialize(c.description_of_σ; pars),
    "support" => c.support)


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

# test here
# serialize(cM_running_σ.model_r; pars = (σ = 0.1,))


serialize(c::ConstructorOfPol1; pars) = LittleDict(
    "type" => "ConstructorOfPol1",
    "description_of_c1" => serialize(c.description_of_c1; pars),
    "support" => c.support)

# test here
# serialize(cM_running_σ.model_b; pars = (σ = 0.1,))

serialize(c::ConstructorOfPRBModel; pars) = LittleDict(
    "type" => "ConstructorOfPRBModel",
    "model_p" => serialize(c.model_p; pars),
    "model_r" => serialize(c.model_r; pars),
    "model_b" => serialize(c.model_b; pars),
    "description_of_fs" => serialize(c.description_of_fs; pars),
    "support" => c.support)

# test here
serialize(cM_running_w; pars = (w = 0.5,))


open(joinpath(@__DIR__, "test-serialization.json"), "w") do f
    JSON.print(f, Dict(
        "my_model" => serialize(cM_running_σ; pars = (σ = 0.1,))
    ))
end



bin1_res = ConstructorOfTwoComponentModel(
    ConstructorOfGaussian(Fixed(0), Fixed(0.1), (-0.6, 0.6)),
    ConstructorOfGaussian(Fixed(0), Fixed(0.2), (-0.6, 0.6)),
    Fixed(0.5)
)

bin2_res = ConstructorOfTwoComponentModel(
    ConstructorOfGaussian(Fixed(0), Fixed(0.15), (-0.6, 0.6)),
    ConstructorOfGaussian(Fixed(0), Fixed(0.25), (-0.6, 0.6)),
    Fixed(0.6)
)

bg_bin1 = ConstructorOfPol1(Running("c1_bin1"), (1.1, 2.5))
bg_bin2 = ConstructorOfPol1(Running("c1_bin2"), (1.1, 2.5))


open(joinpath(@__DIR__, "test-serialization-bins.json"), "w") do f
    pars = (c1_bin1 = 0.1, c1_bin2 = 0.2)
    JSON.print(f, Dict(
        "bin1" => LittleDict(
            "RES" => serialize(bin1_res; pars = NamedTuple()),
            "BG" => serialize(bg_bin1; pars)
        ),
        "bin2" => LittleDict(
            "RES" => serialize(bin2_res; pars = NamedTuple()),
            "BG" => serialize(bg_bin2; pars)
        )
    ))
end


two_bins_data = open(io->JSON.parse(io), joinpath(@__DIR__, "test-serialization-bins.json"))

let
    all_fields = two_bins_data["bin1"]["BG"]
    t = all_fields["type"] |> Meta.parse |> eval
    c, s = deserialize(t, all_fields)
    s
end