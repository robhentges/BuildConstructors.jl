abstract type AbstractConstructor end

# for all constructors, apply the function to all fields
for func in (:fix!, :release!, :update!)
    @eval function $func(c::AbstractConstructor, pars)
        for field in fieldnames(typeof(c))
            $func(getfield(c, field), pars)
        end
    end
end

# collection functionality
function pickup(c::AbstractConstructor)
    _list = NamedTuple()
    for field in fieldnames(typeof(c))
        _list = merge(_list, pickup(getfield(c, field)))
    end
    return _list
end
