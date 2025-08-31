module TestFunctionRedefinition

using LuaNova
using Test

function mysum(a::Float64, b::Float64)
    return a + b
end
@define_lua_function mysum

function mysum(a::String, b::String)
    return a * b
end
@define_lua_function mysum

function mysum(a::Bool, b::Bool)
    return a && b
end
@define_lua_function mysum

end
