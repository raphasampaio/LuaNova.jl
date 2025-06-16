module TestMutableStructs

using LuaNova
using Test

mutable struct Point
    x::Float64
    y::Float64
end
@define_lua_struct Point

function increase(p::Point, x::Float64, y::Float64)
    p.x += x
    p.y += y
    return nothing
end
@define_lua_function increase

function sum(p::Point)
    return p.x + p.y
end
@define_lua_function sum

function to_string(p::Point)
    return "Point($(p.x), $(p.y))"
end
@define_lua_function to_string

function add(p1::Point, p2::Point)
    return Point(p1.x + p2.x, p1.y + p2.y)
end
@define_lua_function add

@testset "Mutable Structs" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_struct(
        L,
        Point,
        "increase", increase,
        "sum", sum,
        "__tostring", to_string,
        "__add", add,
    )

    LuaNova.safe_script(L, "p = Point(1.0, 2.0)")
    LuaNova.safe_script(L, "return p.x")
    @test LuaNova.to_number(L, -1) == 1.0
    LuaNova.safe_script(L, "return p.y")
    @test LuaNova.to_number(L, -1) == 2.0

    LuaNova.safe_script(L, "p = Point(1.0, 2.0)")
    LuaNova.safe_script(L, "p.x = 3.0")
    LuaNova.safe_script(L, "return p.x")
    @test LuaNova.to_number(L, -1) == 3.0
    LuaNova.safe_script(L, "p.y = 4.0")
    LuaNova.safe_script(L, "return p.y")
    @test LuaNova.to_number(L, -1) == 4.0
    LuaNova.safe_script(L, "return p:sum()")
    @test LuaNova.to_number(L, -1) == 7.0
    LuaNova.safe_script(L, "return tostring(p)")
    @test LuaNova.to_string(L, -1) == "Point(3.0, 4.0)"

    LuaNova.safe_script(L, "p = Point(1.0, 2.0)")
    LuaNova.safe_script(L, "p:increase(2.0, 3.0)")
    LuaNova.safe_script(L, "return p")
    result = LuaNova.to_userdata(L, -1, Point)
    @test result.x == 3.0
    @test result.y == 5.0

    LuaNova.safe_script(L, "p1 = Point(1.0, 2.0)")
    LuaNova.safe_script(L, "p2 = Point(3.0, 4.0)")
    LuaNova.safe_script(L, "return p1 + p2")
    result = LuaNova.to_userdata(L, -1, Point)
    @test result.x == 4.0
    @test result.y == 6.0

    LuaNova.close(L)

    return nothing
end

end
