module TestMutableStructsWithState

using LuaNova
using Test

mutable struct Struct1
    x::Float64

    function Struct1(L::LuaState, x::Float64)
        @test typeof(L) == Ptr{LuaNova.C.lua_State}
        return new(x)
    end
end
@define_lua_struct Struct1

mutable struct Struct2
    x::Float64

    function Struct2(L::LuaState)
        @test typeof(L) == Ptr{LuaNova.C.lua_State}
        return new(2.0)
    end
end
@define_lua_struct Struct2

@testset "Mutable structs with state" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_struct(L, Struct1)
    @push_lua_struct(L, Struct2)

    LuaNova.safe_script(L, "s1 = Struct1(1.0)")
    LuaNova.safe_script(L, "return s1.x")
    @test LuaNova.to_number(L, -1) == 1.0

    LuaNova.safe_script(L, "s2 = Struct2()")
    LuaNova.safe_script(L, "return s2.x")
    @test LuaNova.to_number(L, -1) == 2.0

    LuaNova.close(L)

    return nothing
end

end
