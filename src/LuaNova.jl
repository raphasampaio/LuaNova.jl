module LuaNova

export 
    from_lua,
    to_lua,
    register_lua,
    to_cstring,
    @define_lua_function, 
    @push_lua_function,
    LuaError

include("capi.jl")
import .C

const LuaState = Union{Ptr{C.lua_State}, Ptr{Nothing}}

const USERDATA_CONVERTERS = Dict()

include("util.jl")
include("error.jl")
include("intermediate.jl")
include("state.jl")
include("macros.jl")

end
