module LuaNova

export
    from_lua,
    to_cstring,
    @define_lua_function,
    @define_lua_function_with_state,
    @define_lua_struct,
    @define_lua_struct_with_state,
    @push_lua_function,
    @push_lua_struct,
    @push_lua_enumx,
    lua_table_to_vector,
    lua_table_to_dict,
    LuaState,
    LuaError

include("capi.jl")
import .C

using EnumX

const LuaState = Union{Ptr{C.lua_State}, Ptr{Nothing}}

include("util.jl")
include("error.jl")
include("intermediate.jl")
include("state.jl")
include("macros.jl")
include("registry.jl")

end
