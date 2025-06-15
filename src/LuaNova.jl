module LuaNova

export 
    from_lua,
    to_lua,
    register_lua,
    to_cstring,
    @define_lua_function, 
    @push_lua_function,
    @define_lua_struct,
    @push_lua_struct,
    _push_lua_field,
    LuaError

include("capi.jl")
import .C

const LuaState = Union{Ptr{C.lua_State}, Ptr{Nothing}}

# Registry to hold the references so they are not gc’d
const REGISTRY = IdDict{Ptr{Cvoid}, Ref}()

function get_reference(L::LuaState, idx::Integer, name::String)
    ud = LuaNova.C.luaL_checkudata(L, idx, to_cstring(name))
    return LuaNova.REGISTRY[Ptr{Cvoid}(ud)][]
end

include("util.jl")
include("error.jl")
include("intermediate.jl")
include("state.jl")
include("macros.jl")

end
