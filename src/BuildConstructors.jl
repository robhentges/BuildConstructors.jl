module BuildConstructors

using Distributions
using NumericalDistributions
using DistributionsHEP
using OrderedCollections
using Parameters

# generic methods
export Fixed
export Running
export serialize
export deserialize
include("parameters.jl")

export Parameter
export fix!
export release!
export update!
export pickup
include("fix-release-pickup-update.jl")

include("abstract-constructor.jl")

export build_model
export ConstructorOfBW
export ConstructorOfBraaten
export ConstructorOfCBpSECH
export ConstructorOfGaussian
export ConstructorOfPol1
export ConstructorOfPol2
include("primitives.jl")

# combined model
export ConstructorOfPRBModel
include("phys-res-bgd-model.jl")


# IO
# registration mechanism
include("register_type.jl")

# serialization/deserialization
export serialize
export deserialize
include("io.jl")

# tooling
export convert_database_to_prb
export load_prb_model_from_json
include("load_model_from_json.jl")

end # module
