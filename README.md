# LuaNova.jl

[![CI](https://github.com/raphasampaio/LuaNova.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/raphasampaio/LuaNova.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/raphasampaio/LuaNova.jl/graph/badge.svg?token=Qkg4DKh6HJ)](https://codecov.io/gh/raphasampaio/LuaNova.jl)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

## Introduction

LuaNova.jl is a lightweight Julia package that makes it easy to embed a Lua interpreter in Julia and expose Julia functions, methods, and structs directly to Lua scripts. With LuaNova you can:

- **Bind Julia functions** (including multiple‐dispatch methods) as global Lua functions  
- **Expose Julia structs** to Lua, complete with methods and [metamethods](https://www.lua.org/manual/5.4/manual.html#2.4) (`__add`, `__tostring`, etc.)  
- **Call Lua code safely** from Julia and convert returned values back into native Julia types

## Getting Started

### Installation

```julia
julia> ] add LuaNova
```

### Example: Binding a function to Lua

```julia
using LuaNova

function combine(a::Float64, b::Float64)
    return a + b
end

function combine(a::String, b::String)
    return a * b
end

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
```

### Example: Binding a struct to Lua

```julia
using LuaNova

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
```

## Contributing

Contributions, bug reports, and feature requests are welcome! Feel free to open an issue or submit a pull request.
