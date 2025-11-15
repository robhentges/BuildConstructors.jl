using BuildConstructors
using Distributions
using NumericalDistributions
using Plots
using FHist
using ComponentArrays
using Minuit2
using Optimization

theme(:boxed)

mutable struct Parameter <: BuildConstructors.AbstractParameter
    name::String
    value::Float64
    fixed::Bool
end
BuildConstructors.value(p::Parameter; pars) = p.fixed ? p.value : getproperty(pars, Symbol(p.name))
Parameter(name, value) = Parameter(name, value, false)

constructor = ConstructorOfPRBModel(
    ConstructorOfBW(
        Parameter("m", 2.0),
        Parameter("Γ", 0.2),
        (1.0, 2.5)
    ),
    ConstructorOfGaussian(
        Fixed(0.0),
        Parameter("σ", 0.1),
        (-0.5, 0.5)
    ),
    ConstructorOfPol1(
        Parameter("c1", 0.3),
        (1.0, 2.5)
    ),
    Parameter("fs", 0.5),
    (1.0, 2.5)
)

constructor.model_p.description_of_m.fixed
getfield(constructor.model_p.description_of_m, :fixed)
setfield!(constructor.model_p.description_of_m, :fixed, true)

# no arguments: fix all parameters
fix!(c) = fix!(c, keys(pickup(c)))
# 
fix!(p::BuildConstructors.AbstractParameter, pars) = nothing
fix!(p::Parameter, pars) = Symbol(p.name) ∈ pars ? setfield!(p, :fixed, true) : nothing
fix!(p::Tuple, pars) = nothing
fix!(p::NamedTuple, pars) = nothing
fix!(p::Number, pars) = nothing

# no arguments: release all parameters
release!(c) = release!(c, keys(pickup(c)))
# 
release!(p::BuildConstructors.AbstractParameter, pars) = nothing
release!(p::Parameter, pars) = Symbol(p.name) ∈ pars ? setfield!(p, :fixed, false) : nothing
release!(p::Tuple, pars) = nothing
release!(p::NamedTuple, pars) = nothing
release!(p::Number, pars) = nothing

function fix!(c::BuildConstructors.AbstractConstructor, pars)
    for field in fieldnames(typeof(c))
        fix!(getfield(c, field), pars)
    end
end
function release!(c::BuildConstructors.AbstractConstructor, pars)
    for field in fieldnames(typeof(c))
        release!(getfield(c, field), pars)
    end
end

function update!(c::BuildConstructors.AbstractConstructor, pars)
    for field in fieldnames(typeof(c))
        update!(getfield(c, field), pars)
    end
end
update!(c::BuildConstructors.AbstractParameter, pars) = nothing
update!(c::Parameter, pars) = Symbol(c.name) ∈ keys(pars) ? setfield!(c, :value, getproperty(pars, Symbol(c.name))) : nothing
update!(c::Tuple, pars) = nothing
update!(c::NamedTuple, pars) = nothing
update!(c::Number, pars) = nothing

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



release!(constructor.model_p)
fix!(constructor.model_p, (:m, :c1))
constructor.model_p.description_of_m
update!(constructor.model_p.description_of_m, (m=1.9,))

fix!(constructor, (:m, :c1))
constructor

model = build_model(constructor, (m = 2.0, Γ = 0.1, σ=0.1, fs=0.5))
plot(x->pdf(model, x), 1.0:0.01:2.5, fillalpha=0.1, fillto=0)



data = rand(model, 10000)
const data0 = copy(data)

h = Hist1D(data; binedges=range(1.0, 2.5, length=40))
plot(h, seriestype=:stepbins, fillto=0, fillalpha=0.1)


pars = ComponentArray(m = 2.0, Γ = 0.1)
build_model(constructor, pars)

minusloglikelihood(m,obs) = -sum(x->log(pdf(m,x)), obs)


function fit_munuit(constructor, data, pars;
        minuit_settings = (strategy=2, tolerance=0.01),
        optimizer_settings = (maxiters = 100,))
    objective(pars) = minusloglikelihood(build_model(constructor, pars), data)
    opf = OptimizationFunction((p,x)->objective(p));
    opp = OptimizationProblem(opf, pars)
    solve(opp, MigradOptimizer(; minuit_settings...); optimizer_settings...)
end



function fit_munuit!(constructor, data)
    pars = ComponentArray(pickup(constructor))
    res = fit_munuit(constructor, data, pars)
    update!(constructor, res.u)
end

let
    l = pickup(constructor)
    new_l = NamedTuple{keys(l)}(collect(l) .* 1.1)
    update!(constructor, new_l)
end


let
    plot_model = build_model(constructor, pickup(constructor))
    plot()
    h = Hist1D(data; binedges=range(1.0, 2.5, length=40))
    plot!(h, nbins=40, fillto=0, fillalpha=0.1, seriestype=:stepbins)
    Δx = h.binedges[1][2] - h.binedges[1][1]
    plot!(x->pdf(plot_model, x) * length(data) * Δx, 1.0:0.01:2.5, fillalpha=0.1, fillto=0)
end




# fit only fraction
fix!(constructor)
release!(constructor, (:m, :Γ))
fit_munuit!(constructor, data)


# fit only physical parameters
fix!(constructor)
release!(constructor, (:m, :c1))
fit_munuit!(constructor, data)

# fit only physical parameters
fix!(constructor)
release!(constructor, (:m, :Γ))
fit_munuit!(constructor, data)

fix!(constructor)
release!(constructor, (:fs, :m))
fit_munuit!(constructor, data)

fix!(constructor)
release!(constructor, (:m, :Γ, :c1, :fs))
fit_munuit!(constructor, data)

fix!(constructor)
release!(constructor, (:σ,))
fit_munuit!(constructor, data)

release!(constructor)
fit_munuit!(constructor, data)

