using Lua

using Aqua
using Test

function mysin(L::Ptr{Cvoid})::Cint
    d = Lua.C.lua_tonumber(L, 1)
    Lua.C.lua_pushnumber(L, sin(d))
    return 1
end

function test_capi()
    L = Lua.new_state()
    Lua.open_libs(L)

    Lua.C.lua_pushcfunction(L, @cfunction(mysin, Cint, (Ptr{Cvoid},)))
    Lua.C.lua_setglobal(L, "sin")

    Lua.get_global(L, "sin")
    Lua.push_number(L, 1)
    Lua.protected_call(L, 1)
    result = Lua.to_number(L, -1)
    @test result ≈ sin(1)

    Lua.close(L)

    return nothing
end

@lua function mysum(a::Float64, b::Float64)
    return a + b
end

@lua function mysum(a::String, b::String)
    return a * b
end

function test_macros()
    L = Lua.new_state()
    Lua.open_libs(L)

    @push_lua_function(L, "sum", mysum)

    Lua.C.lua_getglobal(L, "sum")
    Lua.C.lua_pushnumber(L, 1)
    Lua.C.lua_pushnumber(L, 2)
    Lua.protected_call(L, 2)
    result = Lua.to_number(L, -1)
    @test result == 3

    Lua.C.lua_getglobal(L, "sum")
    Lua.C.lua_pushstring(L, "a")
    Lua.C.lua_pushstring(L, "b")
    Lua.protected_call(L, 2)
    result = Lua.to_string(L, -1)
    @test result == "ab"

    Lua.close(L)

    return nothing
end

function test_all()
    @testset "C API" begin
        test_capi()
    end

    @testset "Macros" begin
        test_macros()
    end

    return nothing
end

test_all()
