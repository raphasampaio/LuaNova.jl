function open_math_lib(L::LuaState)
    return C.luaopen_math(L)
end

function open_string_lib(L::LuaState)
    return C.luaopen_string(L)
end

function open_table_lib(L::LuaState)
    return C.luaopen_table(L)
end

function open_io_lib(L::LuaState)
    return C.luaopen_io(L)
end

function open_os_lib(L::LuaState)
    return C.luaopen_os(L)
end

function open_utf8_lib(L::LuaState)
    return C.luaopen_utf8(L)
end

function open_debug_lib(L::LuaState)
    return C.luaopen_debug(L)
end

function open_package_lib(L::LuaState)
    return C.luaopen_package(L)
end

function open_coroutine_lib(L::LuaState)
    return C.luaopen_coroutine(L)
end

function open_base_lib(L::LuaState)
    return C.luaopen_base(L)
end

function open_libs(L::LuaState)
    return C.luaL_openlibs(L)
end
