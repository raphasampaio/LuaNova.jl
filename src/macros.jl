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
            return LuaNova.to_lua(L, result)
        end
    end)
end

macro push_lua_function(L, lua_function, julia_function)
    return esc(quote
        f = @cfunction($julia_function, Cint, (Ptr{Cvoid},))
        LuaNova.C.lua_pushcfunction($L, f)
        LuaNova.C.lua_setglobal($L, $lua_function)
    end)
end

macro define_lua_struct(struct_name)
    struct_string = string(struct_name)

    return esc(quote
        function $struct_name(L::Ptr{LuaNova.C.lua_State})::Cint
            args = LuaNova.from_lua(L)
            object = $struct_name(args...)

            userdata = LuaNova.C.lua_newuserdatauv(L, Csize_t(0), 0)
            LuaNova.REGISTRY[Ptr{Cvoid}(userdata)] = Ref(object)
            LuaNova.C.luaL_setmetatable(L, to_cstring($struct_string))

            return 1
        end
    end)
end

macro push_lua_struct(L, struct_name, args...)
    n = length(args)
    isodd(n) && error("@push_lua_struct needs key fn pairs (got $n args)")

    struct_string = string(struct_name)

    method_entries = Expr[]
    push!(method_entries, :(LuaNova.C.luaL_Reg(to_cstring("__gc"), @cfunction(Point_gc, Cint, (Ptr{LuaNova.C.lua_State},)))))
    push!(method_entries, :(LuaNova.C.luaL_Reg(to_cstring("__tostring"), @cfunction(Point_tostring, Cint, (Ptr{LuaNova.C.lua_State},)))))
    push!(method_entries, :(LuaNova.C.luaL_Reg(to_cstring("__index"), @cfunction(Point_index, Cint, (Ptr{LuaNova.C.lua_State},)))))
    push!(method_entries, :(LuaNova.C.luaL_Reg(to_cstring("__newindex"), @cfunction(Point_newindex, Cint, (Ptr{LuaNova.C.lua_State},)))))

    for i in 1:2:n
        key = args[i]
        fn = args[i+1]
        push!(method_entries, :(LuaNova.C.luaL_Reg(to_cstring($key), @cfunction($fn, Cint, (Ptr{Cvoid},)))))
    end
    push!(method_entries, :(LuaNova.C.luaL_Reg(C_NULL, C_NULL)))
    methods_vect = Expr(:vect, method_entries...)

    return esc(quote
        LuaNova.C.luaL_newmetatable($L, to_cstring($(struct_string)))

        local methods = $methods_vect
        LuaNova.C.luaL_setfuncs($L, pointer(methods), 0)

        LuaNova.C.lua_pop($L, 1)

        LuaNova.C.lua_pushcclosure($L, @cfunction(Point, Cint, (Ptr{LuaNova.C.lua_State},)), 0)
        LuaNova.C.lua_setglobal($L, to_cstring("Point"))
    end)
end