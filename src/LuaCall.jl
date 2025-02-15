module LuaCall

export safe_script

include("capi.jl")
import .C

include("state.jl")

end
