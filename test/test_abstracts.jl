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

@testset "Abstracts 1" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_struct(L, Car, ["move" => move])
    @push_lua_struct(L, Truck, ["move" => move])

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

abstract type Expression end

function save(::Expression)
    return true
end
@define_lua_function save

mutable struct Data <: Expression end
@define_lua_struct Data

mutable struct Binary <: Expression
    left::Expression
    right::Expression
end

abstract type Collection end

mutable struct Thermal <: Collection end
@define_lua_struct Thermal

function load(::Thermal)
    return Data()
end
@define_lua_function load

@testset "Abstracts 2" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_struct(L, Data, ["save" => save])
    @push_lua_struct(L, Thermal, ["load" => load])

    LuaNova.safe_script(L, "thermal = Thermal()")
    LuaNova.safe_script(L, "exp = thermal:load()")
    LuaNova.safe_script(L, "return exp:save()")
    result = LuaNova.to_boolean(L, -1)
    @test result == true

    LuaNova.close(L)

    return nothing
end

end
