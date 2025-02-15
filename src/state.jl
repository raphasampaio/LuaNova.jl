function safe_script(L, str::String)
    return C.luaL_loadstring(L, str) == 1 || C.lua_pcallk(L, 0, Int32(C.LUA_MULTRET), 0, 0, C_NULL) == 1
end