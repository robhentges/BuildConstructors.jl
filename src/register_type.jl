# Type registry for extensible deserialization
const _type_registry = Dict{String, Type}()

"""
    register_type(type_name::String, type::Type)

Register a custom type for deserialization. This allows users to define custom parameter types
or model constructors that can be properly deserialized from JSON.

# Example
```julia
struct MyParameter <: BuildConstructors.AbstractParameter
end

BuildConstructors.register_type("MyParameter", MyParameter)
```

After registration, types serialized with `"type" => "MyParameter"` can be deserialized.
"""
function register_type(type_name::String, type::Type)
    _type_registry[type_name] = type
    return nothing
end

"""
    _type_from_string(type_name::String) -> Type

Internal function to convert a type name string to a Type.
First checks the registry, then falls back to eval in the module scope.
"""
function _type_from_string(type_name::String)
    # First check registry for user-registered types
    if haskey(_type_registry, type_name)
        return _type_registry[type_name]
    end
    # Fall back to eval for built-in types (backward compatibility)
    return Meta.parse(type_name) |> eval
end
