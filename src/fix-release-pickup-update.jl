mutable struct Parameter <: BuildConstructors.AbstractParameter
    name::String
    value::Float64
    fixed::Bool
end
BuildConstructors.value(p::Parameter; pars) =
    p.fixed ? p.value : getproperty(pars, Symbol(p.name))
Parameter(name, value) = Parameter(name, value, false)



# no arguments: fix all parameters
fix!(c) = fix!(c, keys(pickup(c)))
# 
fix!(p::BuildConstructors.AbstractParameter, par_names) = nothing
fix!(p::Parameter, par_names) =
    Symbol(p.name) ∈ par_names ? setfield!(p, :fixed, true) : nothing
fix!(p::Tuple, par_names) = nothing
fix!(p::NamedTuple, par_names) = nothing
fix!(p::Number, par_names) = nothing

# no arguments: release all parameters
release!(c) = release!(c, keys(pickup(c)))
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


# for all constructors, apply the function to all fields
for func in (:fix!, :release!, :update!)
    @eval function $func(c::BuildConstructors.AbstractConstructor, pars)
        for field in fieldnames(typeof(c))
            $func(getfield(c, field), pars)
        end
    end
end


# collection functionality
function pickup(c::BuildConstructors.AbstractConstructor)
    _list = NamedTuple()
    for field in fieldnames(typeof(c))
        _list = merge(_list, pickup(getfield(c, field)))
    end
    return _list
end
pickup(c::Parameter) = NamedTuple{(Symbol(c.name),)}((c.value,))
pickup(c::Running) = NamedTuple{(Symbol(c.name),)}((c.value,))
pickup(c::Fixed) = NamedTuple()
pickup(c::Tuple) = NamedTuple()
pickup(c::Number) = NamedTuple()
