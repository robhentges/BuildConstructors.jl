using BuildConstructors
using Test



cg = ConstructorOfGaussian(Fixed(0.0), Running("σ"), (-0.5, 0.5))

cg_ser = serialize(cg; pars = (σ = 0.1,))
cg_des = deserialize(ConstructorOfGaussian, cg_ser)[1]

@test cg_des == cg


struct FirstParameter <: BuildConstructors.AbstractParameter end
BuildConstructors.value(c::FirstParameter; pars) = pars |> first
BuildConstructors.serialize(c::FirstParameter; pars) = Dict("type" => "FirstParameter")

# Register the custom type for deserialization
BuildConstructors.register!(FirstParameter)

# Implement deserialize for FirstParameter
function BuildConstructors.deserialize(::Type{FirstParameter}, all_fields)
    FirstParameter(), NamedTuple()
end


cg2 = ConstructorOfGaussian(FirstParameter(), Running("σ"), (-0.5, 0.5))

cg2_ser = serialize(cg2; pars = (σ = 0.1,))
cg2_des = deserialize(ConstructorOfGaussian, cg2_ser)[1]

@test cg2_des == cg2
