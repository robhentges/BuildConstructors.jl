mutable struct AdvancedParameter <: AbstractParameter
    name::String
    value::Float64
    boundaries::Tuple{Float64,Float64}
    uncertainty::Float64
    fixed::Bool
end
BuildConstructors.value(p::AdvancedParameter; pars) =
    p.fixed ? p.value : getproperty(pars, Symbol(p.name))
AdvancedParameter(name, value; boundaries=(Inf, -Inf), uncertainty=1.0) =
    AdvancedParameter(name, value, boundaries, uncertainty, false)


fix!(p::AdvancedParameter, par_names) =
    Symbol(p.name) ∈ par_names ? setfield!(p, :fixed, true) : nothing

release!(p::AdvancedParameter, par_names) =
    Symbol(p.name) ∈ par_names ? setfield!(p, :fixed, false) : nothing

update!(c::AdvancedParameter, pars) =
    Symbol(c.name) ∈ keys(pars) ? setfield!(c, :value, getproperty(pars, Symbol(c.name))) :
    nothing

running_values(c::AdvancedParameter) = NamedTuple{(Symbol(c.name),)}((c.value,))

running_uncertainties(p::AdvancedParameter) = NamedTuple{(Symbol(p.name),)}((p.uncertainty,))
running_uncertainties(p::Running) = NamedTuple{(Symbol(p.name),)}((missing,))
running_uncertainties(p::Parameter) = NamedTuple{(Symbol(p.name),)}((missing,))
running_uncertainties(p::Fixed) = NamedTuple()
running_uncertainties(p::Tuple) = NamedTuple()
running_uncertainties(p::Number) = NamedTuple()
# 
running_upper_boundaries(p::AdvancedParameter) = NamedTuple{(Symbol(p.name),)}((p.boundaries[2],))
running_lower_boundaries(p::AdvancedParameter) = NamedTuple{(Symbol(p.name),)}((p.boundaries[1],))
running_upper_boundaries(p::Parameter) = NamedTuple{(Symbol(p.name),)}((Inf,))
running_lower_boundaries(p::Parameter) = NamedTuple{(Symbol(p.name),)}((-Inf,))
running_upper_boundaries(c::Running) = NamedTuple{(Symbol(c.name),)}((Inf,))
running_lower_boundaries(c::Running) = NamedTuple{(Symbol(c.name),)}((-Inf,))

running_upper_boundaries(c::Fixed) = NamedTuple()
running_upper_boundaries(c::Tuple) = NamedTuple()
running_upper_boundaries(c::Number) = NamedTuple()
running_lower_boundaries(c::Fixed) = NamedTuple()
running_lower_boundaries(c::Tuple) = NamedTuple()
running_lower_boundaries(c::Number) = NamedTuple()
