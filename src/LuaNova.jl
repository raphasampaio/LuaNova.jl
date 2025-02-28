module LuaNova

export from_lua, to_lua, @define_lua_function, @push_lua_function

include("capi.jl")
import .C

const LuaState = Union{Ptr{C.lua_State}, Ptr{Nothing}}

include("intermediate.jl")
include("state.jl")
include("macros.jl")

end
