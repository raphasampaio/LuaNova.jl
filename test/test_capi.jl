module TestCAPI

using LuaNova
using Test

function mysin(L::Ptr{Cvoid})::Cint
    d = LuaNova.C.lua_tonumber(L, 1)
    LuaNova.C.lua_pushnumber(L, sin(d))
    return 1
end

@testset "CAPI" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    LuaNova.push_cfunction(L, @cfunction(mysin, Cint, (Ptr{Cvoid},)))
    LuaNova.set_global(L, "sin")

    LuaNova.get_global(L, "sin")
    LuaNova.push!(L, 1)
    LuaNova.protected_call(L, 1)
    result = LuaNova.to_number(L, -1)
    @test result ≈ sin(1)

    LuaNova.close(L)

    return nothing
end

end
