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

function mysum(a::Bool, b::Bool)
    return a && b
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

    LuaNova.get_global(L, "sum")
    LuaNova.push_boolean(L, true)
    LuaNova.push_boolean(L, false)
    LuaNova.protected_call(L, 2)
    result = LuaNova.to_boolean(L, -1)
    @test result == false

    LuaNova.close(L)

    return nothing
end

function test_table()
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    LuaNova.new_table(L)
    LuaNova.push_string(L, "key")
    LuaNova.push_number(L, 42)
    LuaNova.set_table(L, -3)

    LuaNova.push_string(L, "key")
    LuaNova.get_table(L, -2)
    result = LuaNova.to_number(L, -1)
    @test result == 42

    LuaNova.close(L)

    return nothing
end

# function test_error_handling()
#     L = LuaNova.new_state()
#     LuaNova.open_libs(L)

#     LuaNova.push_string(L, "error('test error')")
#     if LuaNova.protected_call(L, 0) != 0
#         error_msg = LuaNova.to_string(L, -1)
#         @test occursin("test error", error_msg)
#     end

#     LuaNova.close(L)

#     return nothing
# end

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

    @testset "Table" begin
        test_table()
    end

    # @testset "Error Handling" begin
    #     test_error_handling()
    # end

    return nothing
end

test_all()
