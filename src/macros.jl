function push_lua_value(L::Ptr{Cvoid}, value)
    if value isa Number
        C.lua_pushnumber(L, value)
    elseif value isa String
        C.lua_pushstring(L, value)
    elseif value isa Ptr
        C.lua_pushlightuserdata(L, value)
    else
        error("Unsupported value type")
    end
end

function pop_lua_value(L::Ptr{Cvoid}, index::Integer)
    C.luaL_checktype(L, index, Lua.TANY)
    t = C.lua_type(L, index)

    if t == Lua.LUA_TNUMBER
        return C.lua_tonumber(L, index)
    elseif t == Lua.LUA_TSTRING
        return C.lua_tostring(L, index)
    elseif t == Lua.LUA_TLIGHTUSERDATA
        return C.lua_touserdata(L, index)
    else
        error("Unsupported Lua value type")
    end
end

macro define_lua_function(function_name)
    return esc(quote
        function $function_name(L::Ptr{Cvoid})::Cint
            args = LuaNova.from_lua(L)
            result = $function_name(args...)
            LuaNova.push_to_lua!(L, result)
            return 1
        end
    end)
end

macro push_lua_function(L, lua_function, julia_function)
    return esc(quote
        f = @cfunction($julia_function, Cint, (Ptr{Cvoid},))
        LuaNova.C.lua_pushcfunction($L, f)
        LuaNova.set_global($L, $lua_function)
    end)
end

macro define_lua_struct(struct_name)
    struct_string = string(struct_name)
    index_function = Symbol(struct_string * "_index")
    new_index_function = Symbol(struct_string * "_newindex")
    garbage_collect_function = Symbol(struct_string * "_gc")

    return esc(quote
        function $struct_name(L::Ptr{LuaNova.C.lua_State})::Cint
            args = LuaNova.from_lua(L)
            object = $struct_name(args...)

            userdata = LuaNova.C.lua_newuserdatauv(L, Csize_t(0), 0)
            LuaNova.REGISTRY[Ptr{Cvoid}(userdata)] = Ref(object)
            LuaNova.set_metatable(L, $struct_string)

            return 1
        end

        function $(index_function)(L::Ptr{LuaNova.C.lua_State})::Cint
            return LuaNova.index(L, $(struct_name))
        end

        function $(new_index_function)(L::Ptr{LuaNova.C.lua_State})::Cint
            return LuaNova.newindex(L, $(struct_name))
        end

        function $(garbage_collect_function)(L::Ptr{LuaNova.C.lua_State})::Cint
            return LuaNova.garbage_collect(L, $(struct_name))
        end
    end)
end

macro push_lua_struct(L, struct_name, args...)
    n = length(args)
    isodd(n) && error("@push_lua_struct needs key fn pairs (got $n args)")

    struct_string = string(struct_name)
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
        LuaNova.push_cfunction($L, @cfunction($struct_name, Cint, (Ptr{LuaNova.C.lua_State},)))
        LuaNova.set_global($L, $struct_string)
    end)
end
