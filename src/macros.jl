macro define_lua_function(function_name::Symbol)
    return esc(quote
        function $function_name(L::LuaState)::Cint
            args = LuaNova.from_lua(L)
            result = $function_name(args...)
            if result isa Tuple
                for value in result
                    LuaNova.push_to_lua!(L, value)
                end
                return length(result)
            else
                LuaNova.push_to_lua!(L, result)
                return 1
            end
        end
    end)
end

macro define_lua_struct_functions(julia_struct::Symbol)
    struct_string = string(julia_struct)
    index_fn = Symbol(struct_string * "_index")
    newindex_fn = Symbol(struct_string * "_newindex")
    gc_fn = Symbol(struct_string * "_gc")

    return esc(quote
        function $(index_fn)(L::Ptr{LuaNova.C.lua_State})::Cint
            return LuaNova.index(L, $(julia_struct))
        end

        function $(newindex_fn)(L::Ptr{LuaNova.C.lua_State})::Cint
            return LuaNova.newindex(L, $(julia_struct))
        end

        function $(gc_fn)(L::Ptr{LuaNova.C.lua_State})::Cint
            return LuaNova.garbage_collect(L, $(julia_struct))
        end
    end)
end

macro define_lua_struct(julia_struct::Symbol)
    struct_string = string(julia_struct)
    new_fn = Symbol(struct_string * "_new")

    return esc(quote
        function $(new_fn)(L::Ptr{LuaNova.C.lua_State})::Cint
            args = LuaNova.from_lua(L)
            result = $julia_struct(args...)
            LuaNova.push_to_lua!(L, result)
            return 1
        end

        LuaNova.@define_lua_struct_functions $julia_struct
    end)
end

macro define_lua_struct_with_state(julia_struct::Symbol)
    struct_string = string(julia_struct)
    new_fn = Symbol(struct_string * "_new")

    return esc(quote
        function $(new_fn)(L::Ptr{LuaNova.C.lua_State})::Cint
            args = LuaNova.from_lua(L)
            result = $julia_struct(L, args...)
            LuaNova.push_to_lua!(L, result)
            return 1
        end

        LuaNova.@define_lua_struct_functions $julia_struct
    end)
end

macro push_lua_function(L::Symbol, lua_function::String, julia_function::Symbol)
    return esc(quote
        f = @cfunction($julia_function, Cint, (Ptr{Cvoid},))
        LuaNova.push_cfunction($L, f)
        LuaNova.set_global($L, $lua_function)
    end)
end

macro push_lua_struct(L::Symbol, julia_struct::Symbol, args...)
    n = length(args)
    isodd(n) && error("@push_lua_struct needs key fn pairs (got $n args)")

    struct_string = string(julia_struct)
    new_fn = Symbol(struct_string * "_new")
    gc_fn = Symbol(struct_string * "_gc")
    index_fn = Symbol(struct_string * "_index")
    newindex_fn = Symbol(struct_string * "_newindex")

    method_entries = Expr[]
    push!(method_entries, :(LuaNova.create_register("__gc", @cfunction($(gc_fn), Cint, (Ptr{LuaNova.C.lua_State},)))))
    push!(
        method_entries,
        :(LuaNova.create_register("__index", @cfunction($(index_fn), Cint, (Ptr{LuaNova.C.lua_State},)))),
    )
    push!(
        method_entries,
        :(LuaNova.create_register("__newindex", @cfunction($(newindex_fn), Cint, (Ptr{LuaNova.C.lua_State},)))),
    )

    for i in 1:2:n
        key = args[i]
        fn = args[i+1]
        push!(method_entries, :(LuaNova.create_register($key, @cfunction($fn, Cint, (Ptr{Cvoid},)))))
    end
    push!(method_entries, :(LuaNova.create_null_register()))
    methods_vect = Expr(:vect, method_entries...)

    return esc(quote
        LuaNova.new_metatable($L, $(struct_string))
        local methods = $methods_vect
        LuaNova.set_functions($L, methods)
        LuaNova.lua_pop!($L, 1)

        LuaNova.push_cfunction($L, @cfunction($(new_fn), Cint, (Ptr{LuaNova.C.lua_State},)))
        LuaNova.set_global($L, $struct_string)
    end)
end

macro define_lua_enumx(enum_name::Symbol)
    register_function = Symbol("register_", enum_name, "_metatable")

    return esc(quote
        # Define a helper function to register the metatable
        function $register_function(L::LuaNova.LuaState)
            # Get the type name using LuaNova's naming convention
            # EnumX creates a type called T inside the module
            first_value = first(instances($enum_name.T))
            type_name = LuaNova.to_string(typeof(first_value))

            # Create metatable with __name field
            LuaNova.new_metatable(L, type_name)
            LuaNova.C.lua_pushstring(L, LuaNova.to_cstring("__name"))
            LuaNova.C.lua_pushstring(L, LuaNova.to_cstring(type_name))
            LuaNova.C.lua_rawset(L, -3)
            LuaNova.C.lua_pop(L, 1)

            return nothing
        end
    end)
end

macro push_lua_enumx(L::Symbol, enum_name::Symbol)
    enum_string = string(enum_name)
    register_function = Symbol("register_", enum_name, "_metatable")

    return esc(quote
        # Register the metatable first
        $register_function($L)

        # Create a table for the enum
        LuaNova.new_table($L)

        # Push all enum values to the table
        for instance in instances($enum_name.T)
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
