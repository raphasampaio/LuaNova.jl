function new_state()
    return C.luaL_newstate()
end

function open_libs(L::LuaState)
    C.luaL_openlibs(L)
    return nothing
end

function close(L::LuaState)
    C.lua_close(L)
    return nothing
end

function protected_call(L::LuaState, nargs::Integer)
    if C.lua_pcallk(L, nargs, 1, 0, 0, C_NULL) != 0
        error("Error calling: ", to_string(L, -1))
    end
    return nothing
end

function to_string(L::LuaState, idx::Integer)
    return unsafe_string(C.lua_tostring(L, idx))
end

function to_number(L::LuaState, idx::Integer)
    return C.lua_tonumber(L, idx)
end

function to_boolean(L::LuaState, idx::Integer)
    return C.lua_toboolean(L, idx) != 0
end

function push_number(L::LuaState, x::Real)
    C.lua_pushnumber(L, x)
    return nothing
end

function push_number(L::LuaState, x::Integer)
    C.lua_pushnumber(L, x)
    return nothing
end

function push_string(L::LuaState, x::String)
    C.lua_pushstring(L, x)
    return nothing
end

function push_boolean(L::LuaState, x::Bool)
    C.lua_pushboolean(L, x)
    return nothing
end

function get_global(L::LuaState, name::String)
    C.lua_getglobal(L, name)
    return nothing
end

function set_global(L::LuaState, name::String)
    C.lua_setglobal(L, name)
    return nothing
end

function push_cfunction(L::LuaState, f::Ptr{Nothing})
    C.lua_pushcfunction(L, f)
    return nothing
end
