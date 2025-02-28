using LuaNova

using Aqua
using Test

include("aqua.jl")

function mysin(L::Ptr{Cvoid})::Cint
    d = LuaNova.C.lua_tonumber(L, 1)
    LuaNova.C.lua_pushnumber(L, sin(d))
    return 1
end

function test_capi()
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    LuaNova.push_cfunction(L, @cfunction(mysin, Cint, (Ptr{Cvoid},)))
    LuaNova.set_global(L, "sin")

    LuaNova.get_global(L, "sin")
    LuaNova.push_number(L, 1)
    LuaNova.protected_call(L, 1)
    result = LuaNova.to_number(L, -1)
    @test result ≈ sin(1)

    LuaNova.close(L)

    return nothing
end

function mysum(a::Float64, b::Float64)
    return a + b
end

function mysum(a::String, b::String)
    return a * b
end

@define_lua_function mysum

function test_macros()
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

    LuaNova.close(L)

    return nothing
end

function test_all()
    @testset "Aqua" begin
        test_aqua()
    end

    @testset "C API" begin
        test_capi()
    end

    @testset "Macros" begin
        test_macros()
    end

    return nothing
end

test_all()
