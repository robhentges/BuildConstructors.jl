"""
    @with_parameters ModelName param1 param2 ... [; field1::Type1, field2::Type2, ...] begin
        # model-building logic
    end

Generate a constructor struct and build_model function for a model with the given parameters.

Constant fields can be specified after a semicolon with their types. Fields used in the body
(e.g., `c.support`) must be explicitly declared.

# Example
```julia
@with_parameters Gaussian μ σ; support::Tuple{Float64,Float64} begin
    truncated(Normal(μ, σ), c.support[1], c.support[2])
end

@with_parameters ComplexModel μ σ; support::Tuple{Float64,Float64}, threshold::Float64 begin
    # Use c.support and c.threshold
end
```
"""

# Helper: Extract begin block from various expression forms
function extract_body(expr)
    if expr isa Expr
        if expr.head == :block
            return expr
        elseif expr.head == :quote
            # Unwrap quote - look for block inside
            for arg in expr.args
                if arg isa Expr && arg.head == :block
                    return arg
                end
            end
            # No block found, create one from args
            return Expr(:block, [a for a in expr.args if !(a isa LineNumberNode)]...)
        end
    end
    return nothing
end

# Helper: Parse field declaration from `field_name::Type` expression
function parse_field_declaration(expr)
    if expr isa Expr && expr.head == :(::) && length(expr.args) == 2
        field_name = expr.args[1]
        field_type = expr.args[2]
        if field_name isa Symbol
            return field_name => field_type
        else
            error("Constant field name must be a symbol, got: $field_name")
        end
    end
    return nothing
end

# Helper: Parse constant fields from parameters expression
function parse_constant_fields_from_params(params_expr, constant_fields, body_ref)
    for kw_arg in params_expr.args
        if kw_arg isa LineNumberNode
            continue
        elseif kw_arg isa Symbol
            # Symbols without type annotation are invalid - fields must have types
            error("Invalid constant field declaration. Expected 'field_name::Type', got: $kw_arg. " *
                  "Constant fields must be declared with a type annotation (e.g., $kw_arg::Type)")
        elseif kw_arg isa Expr
            field_pair = parse_field_declaration(kw_arg)
            if field_pair !== nothing
                push!(constant_fields, field_pair)
                continue
            end
            
            # Check for begin block
            extracted_body = extract_body(kw_arg)
            if extracted_body !== nothing
                body_ref[] = extracted_body
                continue
            end
            
            error("Invalid constant field declaration. Expected 'field_name::Type', got: $kw_arg")
        end
    end
end

# Helper: Parse constant fields from tuple expression
function parse_constant_fields_from_tuple(tuple_expr, constant_fields)
    field_list = tuple_expr.head == :tuple ? tuple_expr.args : tuple_expr.args[2:end]
    for field_decl in field_list
        field_pair = parse_field_declaration(field_decl)
        if field_pair !== nothing
            push!(constant_fields, field_pair)
        else
            error("Invalid constant field declaration. Expected 'field_name::Type', got: $field_decl")
        end
    end
end

# Helper: Find all field usages (_.field_name) in expression tree and transform to c.field_name
# Also validates that fields are accessed via _.field pattern, not directly
function find_field_usages(expr, declared_fields, param_names)
    used_fields = Set{Symbol}()
    invalid_usages = Symbol[]  # Fields used directly without _.field pattern
    
    function traverse_and_transform(e)
        if e isa Expr
            # Check for _.field_name pattern and transform to c.field_name
            if e.head == :. && length(e.args) == 2
                if e.args[1] == :_ && e.args[2] isa QuoteNode
                    field_name = e.args[2].value
                    if field_name isa Symbol
                        push!(used_fields, field_name)
                        # Transform _.field to c.field
                        e.args[1] = :c
                    end
                end
            end
            # Recursively traverse all sub-expressions
            for arg in e.args
                traverse_and_transform(arg)
            end
        elseif e isa Symbol
            # Check if this symbol is a declared field being used directly (invalid)
            # But ignore if it's a parameter name (those are valid)
            if e in declared_fields && !(e in param_names)
                push!(invalid_usages, e)
            end
        end
    end
    
    traverse_and_transform(expr)
    
    # Report invalid usages
    if !isempty(invalid_usages)
        unique_invalid = unique(invalid_usages)
        field_list = join(["'$(f)'" for f in unique_invalid], ", ")
        error("Field(s) $field_list are used directly but must be accessed via '_.field_name' pattern. " *
              "For example, use '_.$(unique_invalid[1])' instead of '$(unique_invalid[1])'")
    end
    
    return used_fields
end

# Helper: Generate type parameters for struct
function generate_type_parameters(n_params)
    # Use fully qualified BuildConstructors.AbstractParameter
    abstract_param_ref = Expr(:., :BuildConstructors, QuoteNode(:AbstractParameter))
    type_param_exprs = Expr[]
    for i in 1:n_params
        type_param = Symbol("T", i)
        push!(type_param_exprs, Expr(:<:, type_param, abstract_param_ref))
    end
    return type_param_exprs
end

# Helper: Generate struct fields
function generate_struct_fields(params, constant_fields, type_param_exprs)
    struct_fields = Expr(:block)
    
    # Add parameter fields: description_of_{param}::T{i}
    for (i, param) in enumerate(params)
        field_name = Symbol("description_of_", param)
        type_param = Symbol("T", i)
        push!(struct_fields.args, Expr(:(::), field_name, type_param))
    end
    
    # Add constant fields (preserve order)
    for (field_name, field_type) in constant_fields
        push!(struct_fields.args, Expr(:(::), field_name, field_type))
    end
    
    return struct_fields
end

# Helper: Generate struct definition
function generate_struct_definition(constructor_name, type_param_exprs, struct_fields)
    # Use fully qualified BuildConstructors.AbstractConstructor
    abstract_constructor_ref = Expr(:., :BuildConstructors, QuoteNode(:AbstractConstructor))
    struct_name_with_params = Expr(:curly, constructor_name, type_param_exprs...)
    return Expr(:struct, false,
        Expr(:<:, struct_name_with_params, abstract_constructor_ref),
        struct_fields
    )
end

# Helper: Generate build_model function
function generate_build_model_function(constructor_name, params, body, mod_name)
    value_ref = Expr(:., mod_name, QuoteNode(:value))
    
    # Extract parameters: param = value(c.description_of_{param}; pars)
    param_extractions = Expr(:block)
    for param in params
        field_name = Symbol("description_of_", param)
        push!(param_extractions.args, 
            Expr(:(=), param, 
                Expr(:call, value_ref, 
                    Expr(:parameters, :pars),
                    Expr(:., :c, QuoteNode(field_name))
                )
            )
        )
    end
    
    # Combine parameter extractions with user body
    build_model_body = Expr(:block)
    append!(build_model_body.args, param_extractions.args)
    
    # Add user body
    if body isa Expr && body.head == :block
        append!(build_model_body.args, body.args)
    else
        push!(build_model_body.args, body)
    end
    
    # Generate function definition
    return Expr(:function,
        Expr(:call, :build_model,
            Expr(:(::), :c, constructor_name),
            :pars
        ),
        build_model_body
    )
end

macro with_parameters(model_name, params_expr...)
    mod = __module__
    mod_name = nameof(mod)
    
    # Extract parameter names, constant fields, and body
    params = Symbol[]
    constant_fields = Pair{Symbol, Union{Symbol, Expr}}[]
    body = Ref{Union{Nothing, Expr}}(nothing)
    
    # Handle case where model_name is a parameters expression (parentheses with semicolon syntax)
    if model_name isa Expr && model_name.head == :parameters
        parse_constant_fields_from_params(model_name, constant_fields, body)
        if length(params_expr) > 0
            model_name = params_expr[1]
            params_expr = params_expr[2:end]
        else
            error("@with_parameters: model name missing when using semicolon syntax")
        end
    end
    
    # Parse remaining arguments
    for arg in params_expr
        if arg isa Symbol
            push!(params, arg)
        elseif arg isa Expr && arg.head == :block
            body[] = arg
            break
        elseif arg isa Expr && arg.head == :call && arg.args[1] == :begin
            body[] = Expr(:block, arg.args[2:end]...)
            break
        elseif arg isa Expr && arg.head == :parameters
            parse_constant_fields_from_params(arg, constant_fields, body)
        elseif arg isa Expr && (arg.head == :tuple || (arg.head == :call && arg.args[1] == :tuple))
            parse_constant_fields_from_tuple(arg, constant_fields)
        else
            error("Unexpected argument format in @with_parameters: $arg")
        end
    end
    
    # Validation
    if body[] === nothing
        error("@with_parameters requires a begin...end block with model-building logic")
    end
    if isempty(params)
        error("@with_parameters requires at least one parameter name")
    end
    
    # Validate field declarations and usage
    declared_fields = Set([pair.first for pair in constant_fields])
    param_names = Set(params)  # Parameter names are valid symbols, not fields
    used_fields = find_field_usages(body[], declared_fields, param_names)
    
    # Check that all used fields are declared
    for field in used_fields
        if !(field in declared_fields)
            error("Field '$(field)' is used in the body but not declared. " *
                  "Please declare it after the semicolon: $(field)::Type")
        end
    end
    
    # Generate code
    model_sym = model_name isa Symbol ? model_name : error("Model name must be a symbol")
    constructor_name = Symbol("ConstructorOf", model_sym)
    
    type_param_exprs = generate_type_parameters(length(params))
    struct_fields = generate_struct_fields(params, constant_fields, type_param_exprs)
    struct_def = generate_struct_definition(constructor_name, type_param_exprs, struct_fields)
    build_model_def = generate_build_model_function(constructor_name, params, body[], mod_name)
    
    return Expr(:block,
        esc(struct_def),
        esc(build_model_def),
        Expr(:line, __source__)
    )
end
