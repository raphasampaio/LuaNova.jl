module TestImmutableStructs

using LuaNova
using Test

struct Point2D
    x::Float64
    y::Float64
end
@define_lua_struct Point2D

@testset "Immutable structs" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_struct(L, Point2D)

    LuaNova.safe_script(L, "p1 = Point2D(1.0, 2.0)")
    LuaNova.safe_script(L, "return p1.x")
    @test LuaNova.to_number(L, -1) == 1.0

    LuaNova.safe_script(L, "return p1.y")
    @test LuaNova.to_number(L, -1) == 2.0

    @test_throws Exception LuaNova.safe_script(L, "p1.x = 3.0")
    @test_throws Exception LuaNova.safe_script(L, "p1.y = 4.0")

    LuaNova.safe_script(L, "return p1.x")
    @test LuaNova.to_number(L, -1) == 1.0

    LuaNova.safe_script(L, "return p1.y")
    @test LuaNova.to_number(L, -1) == 2.0

    LuaNova.close(L)
end
end
