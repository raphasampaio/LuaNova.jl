module TestMutableStructs

using LuaNova
using Test

mutable struct Point
    x::Float64
    y::Float64

    function Point(L::LuaState, x::Float64, y::Float64)
        @show L
        @show typeof(L)
        return new(x, y)
    end
end
@define_lua_struct_with_state Point

@testset "Mutable Structs With State" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_struct(
        L,
        Point,
    )

    LuaNova.safe_script(L, "p = Point(1.0, 2.0)")
    LuaNova.safe_script(L, "return p.x")
    @test LuaNova.to_number(L, -1) == 1.0
    LuaNova.safe_script(L, "return p.y")
    @test LuaNova.to_number(L, -1) == 2.0

    LuaNova.close(L)

    return nothing
end

end
