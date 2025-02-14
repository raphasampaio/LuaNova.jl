using LuaCall

using Aqua
using Test

include("aqua.jl")

function test_simple_example()
    @show L = LuaCall.C.luaL_newstate()

    LuaCall.C.luaL_openlibs(L)

    LuaCall.C.luaL_loadstring(L, "print('Hello, world!')")

    LuaCall.C.lua_close(L)
    
    return nothing
end

function test_all()
    # @testset "Aqua.jl" begin
    #     test_aqua()
    # end

    test_simple_example()

    return nothing
end

test_all()
