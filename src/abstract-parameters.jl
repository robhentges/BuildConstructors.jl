abstract type AbstractParameter end

# Any parameter realization, needs to implement the following functions:
# by default, these functions do nothing
fix!(p::AbstractParameter, par_names) = nothing
release!(p::AbstractParameter, par_names) = nothing
update!(p::AbstractParameter, pars) = nothing
running_values(p::AbstractParameter) = NamedTuple()
running_uncertainties(p::AbstractParameter) = NamedTuple()
running_upper_boundaries(p::AbstractParameter) = NamedTuple()
running_lower_boundaries(p::AbstractParameter) = NamedTuple()


# when applying the methods to any fields it fields, it does nothing 
fix!(p, par_names) = nothing 
release!(p, par_names) = nothing 
update!(p, pars) = nothing 
running_values(p) = NamedTuple() 
running_uncertainties(p) = NamedTuple()
running_upper_boundaries(p) = NamedTuple()
running_lower_boundaries(p) = NamedTuple()


# no arguments: fix all parameters
fix!(c) = fix!(c, keys(running_values(c)))

# no arguments: release all parameters
release!(c) = release!(c, keys(running_values(c)))

