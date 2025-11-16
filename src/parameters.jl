abstract type AbstractParameter end

struct Fixed <: AbstractParameter
    value::Float64
end

struct Running <: AbstractParameter
    name::String
end

value(p::Fixed; pars) = p.value
value(p::Running; pars) = getproperty(pars, Symbol(p.name))
