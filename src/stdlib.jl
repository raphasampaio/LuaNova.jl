function open_math_lib(L::LuaState)
    math_func = cglobal((:luaopen_math, C.liblua), Ptr{Cvoid})
    C.luaL_requiref(L, C.LUA_MATHLIBNAME, math_func, 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_string_lib(L::LuaState)
    string_func = cglobal((:luaopen_string, C.liblua), Ptr{Cvoid})
    C.luaL_requiref(L, C.LUA_STRLIBNAME, string_func, 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_table_lib(L::LuaState)
    table_func = cglobal((:luaopen_table, C.liblua), Ptr{Cvoid})
    C.luaL_requiref(L, C.LUA_TABLIBNAME, table_func, 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_io_lib(L::LuaState)
    io_func = cglobal((:luaopen_io, C.liblua), Ptr{Cvoid})
    C.luaL_requiref(L, C.LUA_IOLIBNAME, io_func, 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_os_lib(L::LuaState)
    os_func = cglobal((:luaopen_os, C.liblua), Ptr{Cvoid})
    C.luaL_requiref(L, C.LUA_OSLIBNAME, os_func, 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_utf8_lib(L::LuaState)
    utf8_func = cglobal((:luaopen_utf8, C.liblua), Ptr{Cvoid})
    C.luaL_requiref(L, C.LUA_UTF8LIBNAME, utf8_func, 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_debug_lib(L::LuaState)
    debug_func = cglobal((:luaopen_debug, C.liblua), Ptr{Cvoid})
    C.luaL_requiref(L, C.LUA_DBLIBNAME, debug_func, 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_package_lib(L::LuaState)
    package_func = cglobal((:luaopen_package, C.liblua), Ptr{Cvoid})
    C.luaL_requiref(L, C.LUA_LOADLIBNAME, package_func, 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_coroutine_lib(L::LuaState)
    coroutine_func = cglobal((:luaopen_coroutine, C.liblua), Ptr{Cvoid})
    C.luaL_requiref(L, C.LUA_COLIBNAME, coroutine_func, 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_base_lib(L::LuaState)
    base_func = cglobal((:luaopen_base, C.liblua), Ptr{Cvoid})
    C.luaL_requiref(L, C.LUA_GNAME, base_func, 1)
    C.lua_pop(L, 1)
    return nothing
end

function open_libs(L::LuaState)
    C.luaL_openlibs(L)
    return nothing
end
