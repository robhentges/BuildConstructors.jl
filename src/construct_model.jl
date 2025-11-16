abstract type AbstractParameter end

struct Fixed <: AbstractParameter
    value::Float64
end

struct Running <: AbstractParameter
    name::String
end

value(p::Fixed; pars) = p.value
value(p::Running; pars) = getproperty(pars, Symbol(p.name))

# Auto-register built-in types
register!(Fixed)
register!(Running)

abstract type AbstractConstructor end

struct ConstructorOfPRBModel{PHYS,RES,BG,T} <: AbstractConstructor
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


function deserialize(::Type{<:Fixed}, all_fields)
    value = all_fields["value"]
    Fixed(value), NamedTuple()
end

function deserialize(::Type{<:Running}, all_fields)
    name = all_fields["name"]
    starting_value = all_fields["starting_value"]
    Running(name), NamedTuple{(Symbol(name),)}((starting_value,))
end


function deserialize(::Type{<:ConstructorOfPRBModel}, all_fields)
    appendix = NamedTuple()


    description_of_p = all_fields["model_p"]
    type_p = _type_from_string(description_of_p["type"])
    model_p, appendix_p = deserialize(type_p, description_of_p)
    appendix = merge(appendix, appendix_p)

    description_of_r = all_fields["model_r"]
    type_r = _type_from_string(description_of_r["type"])
    model_r, appendix_r = deserialize(type_r, description_of_r)
    appendix = merge(appendix, appendix_r)

    description_of_b = all_fields["model_b"]
    type_b = _type_from_string(description_of_b["type"])
    model_b, appendix_b = deserialize(type_b, description_of_b)
    appendix = merge(appendix, appendix_b)

    description_of_fs = all_fields["description_of_fs"]
    type_fs = _type_from_string(description_of_fs["type"])
    description_of_fs, appendix_fs = deserialize(type_fs, description_of_fs)
    appendix = merge(appendix, appendix_fs)

    support = all_fields["support"] |> Tuple
    ConstructorOfPRBModel(model_p, model_r, model_b, description_of_fs, support), appendix
end


serialize(c::Fixed; pars) = LittleDict("type" => "Fixed", "value" => c.value)
serialize(c::Running; pars) =
    LittleDict("type" => "Running", "name" => c.name, "starting_value" => value(c; pars))



serialize(c::ConstructorOfPRBModel; pars) = LittleDict(
    "type" => "ConstructorOfPRBModel",
    "model_p" => serialize(c.model_p; pars),
    "model_r" => serialize(c.model_r; pars),
    "model_b" => serialize(c.model_b; pars),
    "description_of_fs" => serialize(c.description_of_fs; pars),
    "support" => c.support,
)

# Auto-register ConstructorOfPRBModel
register!(ConstructorOfPRBModel)
