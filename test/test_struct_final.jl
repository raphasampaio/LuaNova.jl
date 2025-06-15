module TestMacros

using LuaNova
using Test

mutable struct Point
    x::Float64
    y::Float64
end

@define_lua_struct Point

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
