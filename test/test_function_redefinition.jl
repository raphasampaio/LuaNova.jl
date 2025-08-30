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

@testset "Function redefinition" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_function(L, "sum", mysum)

    LuaNova.close(L)

    return nothing
end

end
