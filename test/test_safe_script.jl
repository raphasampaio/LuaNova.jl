module TestSafeScript

using LuaNova
using Test

@testset "Safe Script" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)
    LuaNova.safe_script(L, "return 42")
    result = LuaNova.to_number(L, -1)
    @test result == 42
    LuaNova.close(L)

    L = LuaNova.new_state()
    LuaNova.open_libs(L)
    LuaNova.safe_script(L, "a = 1")
    vals = LuaNova.from_lua(L)
    @test length(vals) == 0
    LuaNova.close(L)

    L = LuaNova.new_state()
    LuaNova.open_libs(L)
    @test_throws LuaError LuaNova.safe_script(L, "error('test error')")
    LuaNova.close(L)

    L = LuaNova.new_state()
    LuaNova.open_libs(L)
    LuaNova.safe_script(L, "a = 1")
    LuaNova.safe_script(L, "print(a)")
    LuaNova.close(L)
end

end
