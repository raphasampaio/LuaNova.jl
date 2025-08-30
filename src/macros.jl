build_binding_new(s::Symbol) = Symbol("luanova_", s, "_new")
build_binding_index(s::Symbol) = Symbol("luanova_", s, "_index")
build_binding_new_index(s::Symbol) = Symbol("luanova_", s, "_newindex")
build_binding_gc(s::Symbol) = Symbol("luanova_", s, "_gc")
build_binding_function(s::Symbol) = Symbol("luanova_", s, "_function")

macro define_lua_function(julia_function::Symbol)
    binding_function = build_binding_function(julia_function)

    return esc(quote
        if !@isdefined($binding_function)
            function $binding_function(L::LuaState)::Cint
                args = LuaNova.from_lua(L)
                result = $julia_function(args...)
                return LuaNova.push_to_lua!(L, result)
            end
        end
    end)
end

macro define_lua_function_with_state(julia_function::Symbol)
    binding_function = build_binding_function(julia_function)

    return esc(quote
        function $binding_function(L::LuaState)::Cint
            args = LuaNova.from_lua(L)
            result = $julia_function(L, args...)
            return LuaNova.push_to_lua!(L, result)
        end
    end)
end

macro define_lua_struct_functions(julia_struct::Symbol)
    binding_index = build_binding_index(julia_struct)
    binding_new_index = build_binding_new_index(julia_struct)
    binding_gc = build_binding_gc(julia_struct)

    return esc(quote
        function $binding_index(L::LuaState)::Cint
            return LuaNova.index(L, $julia_struct)
        end

        function $binding_new_index(L::LuaState)::Cint
            return LuaNova.newindex(L, $julia_struct)
        end

        function $binding_gc(L::LuaState)::Cint
            return LuaNova.garbage_collect(L, $julia_struct)
        end
    end)
end

macro define_lua_struct(julia_struct::Symbol)
    binding_new = build_binding_new(julia_struct)

    return esc(quote
        function $binding_new(L::LuaState)::Cint
            args = LuaNova.from_lua(L)
            result = $julia_struct(args...)
            LuaNova.push_to_lua!(L, result)
            return 1
        end

        LuaNova.@define_lua_struct_functions $julia_struct
    end)
end

macro define_lua_struct_with_state(julia_struct::Symbol)
    binding_new = build_binding_new(julia_struct)

    return esc(quote
        function $binding_new(L::LuaState)::Cint
            args = LuaNova.from_lua(L)
            result = $julia_struct(L, args...)
            LuaNova.push_to_lua!(L, result)
            return 1
        end

        LuaNova.@define_lua_struct_functions $julia_struct
    end)
end

macro push_lua_function(L::Symbol, lua_function::String, julia_function::Symbol)
    binding_function = build_binding_function(julia_function)

    return esc(quote
        LuaNova.push_cfunction($L, @cfunction($binding_function, Cint, (Ptr{Cvoid},)))
        LuaNova.set_global($L, $lua_function)
    end)
end

macro push_lua_struct(L::Symbol, julia_struct::Symbol, args...)
    n = length(args)
    isodd(n) && error("@push_lua_struct needs key fn pairs (got $n args)")

    julia_struct_string = string(julia_struct)
    binding_new = build_binding_new(julia_struct)
    binding_gc = build_binding_gc(julia_struct)
    binding_index = build_binding_index(julia_struct)
    binding_new_index = build_binding_new_index(julia_struct)

    method_entries = Expr[]

    push!(
        method_entries,
        :(LuaNova.create_register("__gc", @cfunction($binding_gc, Cint, (Ptr{LuaNova.C.lua_State},)))),
    )

    push!(
        method_entries,
        :(LuaNova.create_register("__index", @cfunction($binding_index, Cint, (Ptr{LuaNova.C.lua_State},)))),
    )

    push!(
        method_entries,
        :(LuaNova.create_register("__newindex", @cfunction($binding_new_index, Cint, (Ptr{LuaNova.C.lua_State},)))),
    )

    for i in 1:2:n
        key = args[i]
        binding_function = build_binding_function(args[i+1])
        push!(
            method_entries,
            :(LuaNova.create_register($key, @cfunction($binding_function, Cint, (Ptr{Cvoid},)))),
        )
    end

    push!(
        method_entries,
        :(LuaNova.create_null_register()),
    )

    methods_vector = Expr(:vect, method_entries...)

    return esc(quote
        LuaNova.new_metatable($L, $julia_struct_string)
        local methods = $methods_vector
        LuaNova.set_functions($L, methods)
        LuaNova.lua_pop!($L, 1)

        LuaNova.push_cfunction($L, @cfunction($binding_new, Cint, (Ptr{LuaNova.C.lua_State},)))
        LuaNova.set_global($L, $julia_struct_string)
    end)
end

macro push_lua_enumx(L::Symbol, enum::Symbol)
    enum_string = string(enum)

    return esc(quote
        # Get the type name using LuaNova's naming convention
        # EnumX creates a type called T inside the module
        first_value = first(instances($enum.T))
        type_name = LuaNova.to_string(typeof(first_value))

        # Create metatable with __name field
        LuaNova.new_metatable(L, type_name)
        LuaNova.C.lua_pushstring(L, LuaNova.to_cstring("__name"))
        LuaNova.C.lua_pushstring(L, LuaNova.to_cstring(type_name))
        LuaNova.C.lua_rawset(L, -3)
        LuaNova.C.lua_pop(L, 1)

        # Create a table for the enum
        LuaNova.new_table($L)

        # Push all enum values to the table
        for instance in instances($enum.T)
            value_name = string(instance)
            # Remove the module prefix (e.g., "Main.Color.Red" -> "Red")
            clean_name = split(value_name, '.')[end]

            LuaNova.push_to_lua!($L, instance)
            LuaNova.C.lua_setfield($L, -2, LuaNova.to_cstring(clean_name))
        end

        # Set the table as a global with the enum name
        LuaNova.set_global($L, $enum_string)
    end)
end
