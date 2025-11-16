mutable struct Parameter <: BuildConstructors.AbstractParameter
    name::String
    value::Float64
    fixed::Bool
end
BuildConstructors.value(p::Parameter; pars) =
    p.fixed ? p.value : getproperty(pars, Symbol(p.name))
Parameter(name, value) = Parameter(name, value, false)


# no arguments: fix all parameters
fix!(c) = fix!(c, keys(running_values(c)))
# 
fix!(p::BuildConstructors.AbstractParameter, par_names) = nothing
fix!(p::Parameter, par_names) =
    Symbol(p.name) ∈ par_names ? setfield!(p, :fixed, true) : nothing
fix!(p::Tuple, par_names) = nothing
fix!(p::NamedTuple, par_names) = nothing
fix!(p::Number, par_names) = nothing

# no arguments: release all parameters
release!(c) = release!(c, keys(running_values(c)))
# 
release!(p::BuildConstructors.AbstractParameter, par_names) = nothing
release!(p::Parameter, par_names) =
    Symbol(p.name) ∈ par_names ? setfield!(p, :fixed, false) : nothing
release!(p::Tuple, par_names) = nothing
release!(p::NamedTuple, par_names) = nothing
release!(p::Number, par_names) = nothing

# update
update!(c::BuildConstructors.AbstractParameter, pars) = nothing
update!(c::Parameter, pars) =
    Symbol(c.name) ∈ keys(pars) ? setfield!(c, :value, getproperty(pars, Symbol(c.name))) :
    nothing
update!(c::Tuple, pars) = nothing
update!(c::NamedTuple, pars) = nothing
update!(c::Number, pars) = nothing

# retrieve the value of the parameter
running_values(c::Parameter) = NamedTuple{(Symbol(c.name),)}((c.value,))
running_values(c::Running) = NamedTuple{(Symbol(c.name),)}((missing,))
running_values(c::Fixed) = NamedTuple()
running_values(c::Tuple) = NamedTuple()
running_values(c::Number) = NamedTuple()
