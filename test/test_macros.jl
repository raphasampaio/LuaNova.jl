module TestMacros

using LuaNova
using Test

function mysum(a::Float64, b::Float64)
    return a + b
end

function mysum(a::String, b::String)
    return a * b
end

function mysum(a::Bool, b::Bool)
    return a && b
end

@define_lua_function mysum

@testset "Macros" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_function(L, "sum", mysum)

    LuaNova.get_global(L, "sum")
    LuaNova.push_to_lua!(L, 1)
    LuaNova.push_to_lua!(L, 2)
    LuaNova.protected_call(L, 2)
    result = LuaNova.to_number(L, -1)
    @test result == 3

    LuaNova.get_global(L, "sum")
    LuaNova.push_to_lua!(L, "a")
    LuaNova.push_to_lua!(L, "b")
    LuaNova.protected_call(L, 2)
    result = LuaNova.to_string(L, -1)
    @test result == "ab"

    LuaNova.get_global(L, "sum")
    LuaNova.push_to_lua!(L, true)
    LuaNova.push_to_lua!(L, false)
    LuaNova.protected_call(L, 2)
    result = LuaNova.to_boolean(L, -1)
    @test result == false

    LuaNova.close(L)

    return nothing
end

end
