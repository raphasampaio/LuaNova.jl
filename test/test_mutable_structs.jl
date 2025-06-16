module TestMutableStructs

using LuaNova
using Test

mutable struct Point
    x::Float64
    y::Float64
end
@define_lua_struct Point

function add(p::Point, x::Float64, y::Float64)
    p.x += x
    p.y += y
    return nothing
end
@define_lua_function add

function subtract(p::Point, x::Float64, y::Float64)
    p.x -= x
    p.y -= y
    return nothing
end
@define_lua_function subtract

function to_string(p::Point)
    return "Point($(p.x), $(p.y))"
end
@define_lua_function to_string

@testset "Mutable Structs" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_struct(
        L,
        Point,
        "add", add,
        "subtract", subtract,
        "__tostring", to_string,
    )

    LuaNova.safe_script(
        L,
        """
local p = Point(1.0, 2.0)
print(p)
p.x = 3.0
print(p.x)
print(p.y)
p:add(10, 20)
print(p)
""",
    )

    LuaNova.close(L)

    return nothing
end

end
