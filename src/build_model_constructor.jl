function _extract_ordered_names_values(pars_any)
    names = map(x -> String(first(keys(x))), pars_any)
    vals = map(x -> first(values(x)), pars_any)
    return names, vals
end

function deserialize(description, tag_set)
    method = description["method"]
    pars_res = description["pars"]
    support_val = description["support"]
    # constructor by name
    c = eval(Meta.parse(method))
    # rename parameters with tag suffix, using declared order
    names_base, values_res = _extract_ordered_names_values(pars_res)
    names_res = (names_base .* "_" .* tag_set)
    renamed_res = NamedTuple{Tuple(Symbol.(names_res))}(Tuple(values_res))
    # normalize support to Tuple
    support_tuple = Tuple(support_val)
    return c, renamed_res, support_tuple
end

function build_model_constructor(tag_physical, tag_set; database)

    appendix = NamedTuple()
    phys_entry = database["physical"][tag_physical]
    # 
    method_CPHYS = phys_entry["method"]
    pars_physical_any = phys_entry["pars"]
    support_phys = phys_entry["support"] |> Tuple
    # 
    CPHYS = eval(Meta.parse(method_CPHYS))
    names_physical, values_physical = _extract_ordered_names_values(pars_physical_any)
    pars_physical = NamedTuple{Tuple(Symbol.(names_physical))}(Tuple(values_physical))
    appendix = merge(appendix, pars_physical)

    # res
    CRES, renamed_res, support_res = deserialize(database["sets"][tag_set]["RES"], tag_set)
    names_res = renamed_res |> keys .|> string
    appendix = merge(appendix, renamed_res)
    
    # bgd
    CBG, renamed_bg, support_bg = deserialize(database["sets"][tag_set]["BG"], tag_set)
    names_bg = renamed_bg |> keys .|> string
    appendix = merge(appendix, renamed_bg)

    # 
    pars_mm = (fs1 = 0.9,)
    name_of_fs = pars_mm |> keys .|> string
    appendix = merge(appendix, pars_mm)
    # 
    ConstructorOfMixtureModel(
        CPHYS(names_physical..., support_phys),
        CRES(names_res..., support_res),
        CBG(names_bg..., support_bg),
        name_of_fs |> first
    ), appendix
end

