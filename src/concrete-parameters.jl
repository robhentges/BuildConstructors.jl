
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# very simple parameters
struct Fixed <: AbstractParameter
    value::Float64
end

value(p::Fixed; pars) = p.value
# other methods are default -- nothing


struct Running <: AbstractParameter
    name::String
end

value(p::Running; pars) = getproperty(pars, Symbol(p.name))
running_values(c::Running) = NamedTuple{(Symbol(c.name),)}((missing,))
running_uncertainties(p::Running) = NamedTuple{(Symbol(p.name),)}((missing,))
running_upper_boundaries(c::Running) = NamedTuple{(Symbol(c.name),)}((Inf,))
running_lower_boundaries(c::Running) = NamedTuple{(Symbol(c.name),)}((-Inf,))


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# mutable parameter, can be fixed and released
mutable struct FlexibleParameter <: AbstractParameter
    name::String
    value::Float64
    fixed::Bool
end
value(p::FlexibleParameter; pars) = p.fixed ? p.value : getproperty(pars, Symbol(p.name))
FlexibleParameter(name, value) = FlexibleParameter(name, value, false)

fix!(p::FlexibleParameter, par_names) =
    Symbol(p.name) ∈ par_names ? setfield!(p, :fixed, true) : nothing
release!(p::FlexibleParameter, par_names) =
    Symbol(p.name) ∈ par_names ? setfield!(p, :fixed, false) : nothing

update!(c::FlexibleParameter, pars) =
    Symbol(c.name) ∈ keys(pars) ? setfield!(c, :value, getproperty(pars, Symbol(c.name))) :
    nothing

running_values(c::FlexibleParameter) = NamedTuple{(Symbol(c.name),)}((c.value,))
running_uncertainties(p::FlexibleParameter) = NamedTuple{(Symbol(p.name),)}((missing,))
running_upper_boundaries(p::FlexibleParameter) = NamedTuple{(Symbol(p.name),)}((Inf,))
running_lower_boundaries(p::FlexibleParameter) = NamedTuple{(Symbol(p.name),)}((-Inf,))



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# advanced parameter, can be fixed and released, and has boundaries and uncertainty
mutable struct AdvancedParameter <: AbstractParameter
    name::String
    value::Float64
    boundaries::Tuple{Float64,Float64}
    uncertainty::Float64
    fixed::Bool
end
value(p::AdvancedParameter; pars) = p.fixed ? p.value : getproperty(pars, Symbol(p.name))
AdvancedParameter(name, value; boundaries = (Inf, -Inf), uncertainty = 1.0) =
    AdvancedParameter(name, value, boundaries, uncertainty, false)

fix!(p::AdvancedParameter, par_names) =
    Symbol(p.name) ∈ par_names ? setfield!(p, :fixed, true) : nothing

release!(p::AdvancedParameter, par_names) =
    Symbol(p.name) ∈ par_names ? setfield!(p, :fixed, false) : nothing

update!(c::AdvancedParameter, pars) =
    Symbol(c.name) ∈ keys(pars) ? setfield!(c, :value, getproperty(pars, Symbol(c.name))) :
    nothing

running_values(c::AdvancedParameter) = NamedTuple{(Symbol(c.name),)}((c.value,))
running_uncertainties(p::AdvancedParameter) =
    NamedTuple{(Symbol(p.name),)}((p.uncertainty,))
running_upper_boundaries(p::AdvancedParameter) =
    NamedTuple{(Symbol(p.name),)}((p.boundaries[2],))
running_lower_boundaries(p::AdvancedParameter) =
    NamedTuple{(Symbol(p.name),)}((p.boundaries[1],))
