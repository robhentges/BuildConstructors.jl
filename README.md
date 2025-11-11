# PRB Model Construction Framework

This repository provides a modular system for constructing composite probability models of the general **Physical ⨂ Resolution + Background** form:


The framework is designed so that each model component is represented by a **constructor object**. These constructors do *not* contain numerical values directly; instead, they hold parameter descriptors that tell the system whether a parameter is:

| Parameter Type | Meaning | Example Usage |
|----------------|---------|----------------|
| `Fixed(value)` | Constant, does not vary in fits | `Fixed(0.1)` |
| `Running(name)` | Free parameter controlled during fitting | `Running("g")` |

Running parameters are automatically collected into a `NamedTuple` during deserialization and passed to model evaluation functions during fitting.

---

## Core Concepts

### Parameter Representation

```julia
struct Fixed <: AbstractParameter
    value::Float64
end

struct Running <: AbstractParameter
    name::String
end

# Numerical values are accessed uniformly:

value(p::Fixed; pars) = p.value
value(p::Running; pars) = getproperty(pars, Symbol(p.name))
```

---

### Complete models used in fits are assembled via:

```julia
struct ConstructorOfPRBModel{PHYS,RES,BG,T}
    model_p::PHYS       # Physical model component
    model_r::RES        # Resolution model component
    model_b::BG         # Background model component
    description_of_fs::T
    support::Tuple{Float64,Float64}   # Fit range
end

# The model is then called by:

model = build_model(constructor, parameter_values)
```
---
## Adding a New Model

To implement a new model (physical, resolution, or background), define a `struct`, `build_model` function, `deserialize` and `serialize` methods:

```julia
struct ConstructorOfMyModel{T1<:AbstractParameter,T2<:AbstractParameter}
    description_of_a::T1
    description_of_b::T2
    support::Tuple{Float64,Float64}
end

function build_model(c::ConstructorOfMyModel, pars)
    a = value(c.description_of_a; pars)
    b = value(c.description_of_b; pars)
    # return model object here
end

function deserialize(::Type{<:ConstructorOfMyModel}, all_fields)
    appendix = NamedTuple()
    
    desc_a_dict = all_fields["description_of_a"]
    type_a = _type_from_string(desc_a_dict["type"])
    desc_a, app_a = deserialize(type_a, desc_a_dict)
    appendix = merge(appendix, app_a)
    
    desc_b_dict = all_fields["description_of_b"]
    type_b = _type_from_string(desc_b_dict["type"])
    desc_b, app_b = deserialize(type_b, desc_b_dict)
    appendix = merge(appendix, app_b)
    
    support = all_fields["support"] |> Tuple
    return ConstructorOfMyModel(desc_a, desc_b, support), appendix
end

serialize(c::ConstructorOfMyModel; pars) = LittleDict(
    "type" => "ConstructorOfMyModel",
    "description_of_a" => serialize(c.description_of_a; pars),
    "description_of_b" => serialize(c.description_of_b; pars),
    "support" => c.support
)
```

**Note:** If you define custom types for parameter or model constructors, you must register them using `register!(TypeName)` so they can be properly deserialized.






