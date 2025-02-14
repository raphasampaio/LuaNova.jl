using LuaCall

using Aqua
using Test

include("aqua.jl")

function test_simple_example()
    @show L = LuaCall.C.luaL_newstate()

    LuaCall.C.luaL_openlibs(L)

    @show LuaCall.C.luaL_loadstring(L, "print('Hello, world!')") || LuaCall.C.lua_pcallk(L, 0, -1, 0, 0, 0)

    @show LuaCall.C.lua_type(L, Cint(-1))

    # @show LuaCall.C.lua_tostring(L, Cint(-1))

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
