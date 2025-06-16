# Registry to hold the references so they are not gc’d
const REGISTRY = IdDict{Ptr{Cvoid}, Ref}()

function get_reference(L::LuaState, idx::Integer, name::String)
    ud = LuaNova.C.luaL_checkudata(L, idx, to_cstring(name))
    return LuaNova.REGISTRY[Ptr{Cvoid}(ud)][]
end