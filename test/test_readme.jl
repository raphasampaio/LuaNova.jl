module TestReadme

using LuaNova
using Test

combine(a::Float64, b::Float64) = a + b
combine(a::String, b::String) = a * b
@define_lua_function combine

L = LuaNova.new_state()
LuaNova.open_libs(L)

@push_lua_function(L, "combine", combine)

LuaNova.safe_script(
    L, """
result1 = combine(3.0, 4.0)
assert(result1 == 7.0)

result2 = combine("Hello, ", "World!")
assert(result2 == "Hello, World!")
""",
)

LuaNova.close(L)

mutable struct Rectangle
    width::Float64
    height::Float64
end
@define_lua_struct Rectangle

function area(r::Rectangle)
    return r.width * r.height
end
@define_lua_function area

function scale!(r::Rectangle, factor::Float64)
    r.width *= factor
    r.height *= factor
    return nothing
end
@define_lua_function scale!

function add(r1::Rectangle, r2::Rectangle)
    return Rectangle(r1.width + r2.width, r1.height + r2.height)
end
@define_lua_function add

function to_string(r::Rectangle)
    return "Rectangle(width=$(r.width), height=$(r.height))"
end
@define_lua_function to_string

L = LuaNova.new_state()
LuaNova.open_libs(L)

@push_lua_struct(
    L,
    Rectangle,
    "area", area,
    "scale", scale!,
    "__add", add,
    "__tostring", to_string,
)

LuaNova.safe_script(
    L, """
r = Rectangle(3.0, 4.0)
area = r:area()
print(r)
assert(area == 12.0)

r:scale(2.0)
area = r:area()
print(r)
assert(area == 48.0)
""",
)

LuaNova.safe_script(
    L, """
r1 = Rectangle(1.0, 2.0)
r2 = Rectangle(3.0, 4.0)
r3 = r1 + r2
print(r3)

assert(r3.width == 4.0)
assert(r3.height == 6.0)
""",
)

LuaNova.close(L)
end
