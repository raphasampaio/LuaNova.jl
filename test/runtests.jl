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
    Lua.C.lua_setglobal(L, "mysin")

    Lua.C.lua_getglobal(L, "mysin")
    Lua.C.lua_pushnumber(L, 1)

    if Lua.C.lua_pcallk(L, 1, 1, 0, 0, C_NULL) != 0
        error("Error calling mysin: ", Lua.C.lua_tostring(L, -1))
    end

    result = Lua.C.lua_tonumber(L, -1)

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

    Lua.safe_script(L, "print(sum(1, 1))")
    Lua.safe_script(L, "print(sum('a', 'b'))")

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
