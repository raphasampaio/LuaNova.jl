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
    if C.lua_pcallk(L, nargs, Int32(C.LUA_MULTRET), 0, 0, C_NULL) != 0
        throw(LuaError(L))
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

function Base.push!(L::LuaState, x::Real)
    C.lua_pushnumber(L, x)
    return nothing
end

function Base.push!(L::LuaState, x::Integer)
    C.lua_pushnumber(L, x)
    return nothing
end

function Base.push!(L::LuaState, x::String)
    C.lua_pushstring(L, x)
    return nothing
end

function Base.push!(L::LuaState, x::Bool)
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

function new_table(L::LuaState)
    C.lua_createtable(L, 0, 0)
    return nothing
end

function set_table(L::LuaState, idx::Integer)
    C.lua_settable(L, idx)
    return nothing
end

function get_table(L::LuaState, idx::Integer)
    C.lua_gettable(L, idx)
    return nothing
end

function arith(L::LuaState, op::String)
    C.lua_arith(L, op)
    return nothing
end

function load_string(L::LuaState, s::String)
    if C.luaL_loadstring(L, s) != 0
        throw(LuaError(L))
    end
    return nothing
end

function new_userdata(L::LuaState, size::Integer)
    return C.lua_newuserdatauv(L, size, 0)
end

function set_metatable(L::LuaState, idx::Integer)
    return C.lua_setmetatable(L, idx)
end

function get_metatable(L::LuaState, idx::Integer)
    return C.lua_getmetatable(L, idx)
end

function to_userdata(L::LuaState, idx::Integer)
    return C.lua_touserdata(L, idx)
end

function check_userdata(L::LuaState, ud::Integer, tname::Ptr{Cchar})
    return LuaNova.C.luaL_checkudata(L, ud, tname)
end
