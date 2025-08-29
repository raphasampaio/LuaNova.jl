function open_math_lib(L::LuaState)
    C.luaopen_math(L)
    C.lua_setglobal(L, C.LUA_MATHLIBNAME)
    return nothing
end

function open_string_lib(L::LuaState)
    C.luaopen_string(L)
    C.lua_setglobal(L, C.LUA_STRLIBNAME)
    return nothing
end

function open_table_lib(L::LuaState)
    C.luaopen_table(L)
    C.lua_setglobal(L, C.LUA_TABLIBNAME)
    return nothing
end

function open_io_lib(L::LuaState)
    C.luaopen_io(L)
    C.lua_setglobal(L, C.LUA_IOLIBNAME)
    return nothing
end

function open_os_lib(L::LuaState)
    C.luaopen_os(L)
    C.lua_setglobal(L, C.LUA_OSLIBNAME)
    return nothing
end

function open_utf8_lib(L::LuaState)
    C.luaopen_utf8(L)
    C.lua_setglobal(L, C.LUA_UTF8LIBNAME)
    return nothing
end

function open_debug_lib(L::LuaState)
    C.luaopen_debug(L)
    C.lua_setglobal(L, C.LUA_DBLIBNAME)
    return nothing
end

function open_package_lib(L::LuaState)
    C.luaopen_package(L)
    C.lua_setglobal(L, C.LUA_LOADLIBNAME)
    return nothing
end

function open_coroutine_lib(L::LuaState)
    C.luaopen_coroutine(L)
    C.lua_setglobal(L, C.LUA_COLIBNAME)
    return nothing
end

function open_base_lib(L::LuaState)
    C.luaopen_base(L)
    C.lua_setglobal(L, C.LUA_GNAME)
    return nothing
end

function open_libs(L::LuaState)
    C.luaL_openlibs(L)
    return nothing
end
