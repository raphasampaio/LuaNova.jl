module TestAbstracts

using LuaNova
using Test

abstract type Vehicle end

mutable struct Car <: Vehicle end
@define_lua_struct Car

mutable struct Truck <: Vehicle end
@define_lua_struct Truck

move(::Vehicle) = "not defined"
move(::Car) = "defined"
@define_lua_function move

@testset "Abstracts" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_struct(L, Car, "move", move)
    @push_lua_struct(L, Truck, "move", move)

    LuaNova.safe_script(L, "c = Car()")
    LuaNova.safe_script(L, "return c:move()")
    result = LuaNova.to_string(L, -1)
    @test result == "defined"

    LuaNova.safe_script(L, "t = Truck()")
    LuaNova.safe_script(L, "return t:move()")
    result = LuaNova.to_string(L, -1)
    @test result == "not defined"

    LuaNova.close(L)

    return nothing
end

end
