function open_math_lib(L::LuaState)
    C.luaL_requiref(L, C.LUA_MATHLIBNAME, @cfunction(C.luaopen_math, Cint, (Ptr{C.lua_State},)), 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_string_lib(L::LuaState)
    C.luaL_requiref(L, C.LUA_STRLIBNAME, @cfunction(C.luaopen_string, Cint, (Ptr{C.lua_State},)), 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_table_lib(L::LuaState)
    C.luaL_requiref(L, C.LUA_TABLIBNAME, @cfunction(C.luaopen_table, Cint, (Ptr{C.lua_State},)), 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_io_lib(L::LuaState)
    C.luaL_requiref(L, C.LUA_IOLIBNAME,  @cfunction(C.luaopen_io, Cint, (Ptr{C.lua_State},)), 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_os_lib(L::LuaState)
    C.luaL_requiref(L, C.LUA_OSLIBNAME, @cfunction(C.luaopen_os, Cint, (Ptr{C.lua_State},)), 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_utf8_lib(L::LuaState)
    C.luaL_requiref(L, C.LUA_UTF8LIBNAME, @cfunction(C.luaopen_utf8, Cint, (Ptr{C.lua_State},)), 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_debug_lib(L::LuaState)
    C.luaL_requiref(L, C.LUA_DBLIBNAME, @cfunction(C.luaopen_debug, Cint, (Ptr{C.lua_State},)), 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_package_lib(L::LuaState)
    C.luaL_requiref(L, C.LUA_LOADLIBNAME,  @cfunction(C.luaopen_package, Cint, (Ptr{C.lua_State},)), 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_coroutine_lib(L::LuaState)
    C.luaL_requiref(L, C.LUA_COLIBNAME, @cfunction(C.luaopen_coroutine, Cint, (Ptr{C.lua_State},)), 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_base_lib(L::LuaState)
    C.luaL_requiref(L, C.LUA_GNAME, @cfunction(C.luaopen_base, Cint, (Ptr{C.lua_State},)), 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_libs(L::LuaState)
    C.luaL_openlibs(L)
    return nothing
end
