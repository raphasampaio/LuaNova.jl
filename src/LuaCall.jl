module LuaCall

include("capi.jl")
import .C

function do_string(L, s)
    return C.luaL_loadstring(L, s) || C.lua_pcallk(L, 0, -1, 0, 0, C_NULL)
end

end
