macro define_lua_function(function_name::Symbol)
    return esc(quote
        function $function_name(L::Ptr{Cvoid})::Cint
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

macro define_lua_struct(julia_struct::Symbol)
    struct_string = string(julia_struct)
    index_function = Symbol(struct_string * "_index")
    new_index_function = Symbol(struct_string * "_newindex")
    garbage_collect_function = Symbol(struct_string * "_gc")

    return esc(quote
        function $julia_struct(L::Ptr{LuaNova.C.lua_State})::Cint
            args = LuaNova.from_lua(L)
            result = $julia_struct(args...)
            LuaNova.push_to_lua!(L, result)
            return 1
        end

        function $(index_function)(L::Ptr{LuaNova.C.lua_State})::Cint
            return LuaNova.index(L, $(julia_struct))
        end

        function $(new_index_function)(L::Ptr{LuaNova.C.lua_State})::Cint
            return LuaNova.newindex(L, $(julia_struct))
        end

        function $(garbage_collect_function)(L::Ptr{LuaNova.C.lua_State})::Cint
            return LuaNova.garbage_collect(L, $(julia_struct))
        end
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
    gc_fn = Symbol(struct_string * "_gc")
    idx_fn = Symbol(struct_string * "_index")
    new_fn = Symbol(struct_string * "_newindex")

    method_entries = Expr[]
    push!(method_entries, :(LuaNova.create_register("__gc", @cfunction($(gc_fn), Cint, (Ptr{LuaNova.C.lua_State},)))))
    push!(method_entries, :(LuaNova.create_register("__index", @cfunction($(idx_fn), Cint, (Ptr{LuaNova.C.lua_State},)))))
    push!(method_entries, :(LuaNova.create_register("__newindex", @cfunction($(new_fn), Cint, (Ptr{LuaNova.C.lua_State},)))))

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

        # constructor
        LuaNova.push_cfunction($L, @cfunction($julia_struct, Cint, (Ptr{LuaNova.C.lua_State},)))
        LuaNova.set_global($L, $struct_string)
    end)
end
