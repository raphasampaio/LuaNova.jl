module TestErrorHandling

using LuaNova
using Test

@testset "Error Handling" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    LuaNova.push!(L, "error('test error')")
    @test_throws LuaError LuaNova.protected_call(L, 0)

    LuaNova.close(L)

    return nothing
end

end
