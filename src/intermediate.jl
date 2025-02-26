function new_state()
    return C.luaL_newstate()
end

function open_libs(L::Ptr{C.lua_State})
    C.luaL_openlibs(L)
    return nothing
end

function close(L::Ptr{C.lua_State})
    C.lua_close(L)
    return nothing
end

function protected_call(L::Ptr{C.lua_State}, nargs::Integer)
    if Lua.C.lua_pcallk(L, nargs, 1, 0, 0, C_NULL) != 0
        error("Error calling: ", to_string(L, -1))
    end
    return nothing
end

function to_string(L::Ptr{C.lua_State}, idx::Integer)
    return unsafe_string(C.lua_tostring(L, idx))
end

function to_number(L::Ptr{C.lua_State}, idx::Integer)
    return C.lua_tonumber(L, idx)
end

function push_number(L::Ptr{C.lua_State}, x::Number)
    C.lua_pushnumber(L, x)
    return nothing
end

function get_global(L::Ptr{C.lua_State}, name::String)
    C.lua_getglobal(L, name)
    return nothing
end