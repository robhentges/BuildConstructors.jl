# load_model_from_json.jl

using JSON, OrderedCollections

function convert_database_to_prb(db, phys, res, bg)
    return OrderedDict(
        "type" => "ConstructorOfPRBModel",

        # you choose which physical component goes here
        "model_p" => db["physical"]["$(phys)"],

        # resolution piece
        "model_r" => db["resolution"]["$(res)"],

        # background
        "model_b" => db["background"]["$(bg)"],

        # mixing fraction fs – here fixed to some value (you may choose)
        "description_of_fs" => db["description_of_fs"],

        # actual fit range — larger than from physical part
        "support" => db["support"],
    )
end

function load_prb_model_from_json(filename, phys, res, bg)
    db = JSON.parsefile(filename; dicttype = OrderedDict)
    converted = convert_database_to_prb(db, phys, res, bg)
    constructor, starting_parameters = deserialize(ConstructorOfPRBModel, converted)
    return constructor, starting_parameters
end
