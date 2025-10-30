function deserialize(description, tag_set)
	pars_res = description.pars
	method = description.method
	# 
	c = eval(Meta.parse(method))
	# rename parameters with intervals
	names_res = (pars_res |> keys .|> string) .* "_" .* tag_set
	renamed_res = NamedTuple{Symbol.(names_res)}(Tuple(pars_res))
	return c, renamed_res, description.support
end

function build_model_constuctor(tag_physical, tag_set; database)

	appendix = NamedTuple()
	# phys
	method_CPHYS = database["physical"][tag_physical].method
	pars_physical = database["physical"][tag_physical].pars
	CPHYS = eval(Meta.parse(method_CPHYS))
	names_physical = pars_physical |> keys .|> string
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
	ConstructorOfMistureModel(
		CPHYS(names_physical..., (1.1, 2.5)),
		CRES(names_res..., support_res),
		CBG(names_bg..., support_bg),
		name_of_fs |> first
	), appendix
end

