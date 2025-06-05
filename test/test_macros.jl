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
    LuaNova.push_number(L, 1)
    LuaNova.push_number(L, 2)
    LuaNova.protected_call(L, 2)
    result = LuaNova.to_number(L, -1)
    @test result == 3

    LuaNova.get_global(L, "sum")
    LuaNova.push_string(L, "a")
    LuaNova.push_string(L, "b")
    LuaNova.protected_call(L, 2)
    result = LuaNova.to_string(L, -1)
    @test result == "ab"

    LuaNova.get_global(L, "sum")
    LuaNova.push_boolean(L, true)
    LuaNova.push_boolean(L, false)
    LuaNova.protected_call(L, 2)
    result = LuaNova.to_boolean(L, -1)
    @test result == false

    LuaNova.close(L)

    return nothing
end

end
