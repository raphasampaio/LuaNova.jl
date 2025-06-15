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
