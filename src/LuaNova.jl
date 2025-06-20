module LuaNova

export
    from_lua,
    to_cstring,
    @define_lua_function,
    @push_lua_function,
    @define_lua_struct,
    @push_lua_struct,
    LuaError

include("capi.jl")
import .C

const LuaState = Union{Ptr{C.lua_State}, Ptr{Nothing}}

include("util.jl")
include("error.jl")
include("intermediate.jl")
include("state.jl")
include("macros.jl")
include("registry.jl")

end
