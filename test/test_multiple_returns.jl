module TestMultipleReturns

using LuaNova
using Test

function multiple_returns()
    return 1, "hello", true
end

@define_lua_function multiple_returns

@testset "Multiple returns" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_function(L, "multiple_returns", multiple_returns)

    LuaNova.safe_script(L, "n, s, b = multiple_returns()")

    LuaNova.safe_script(L, "return n")
    @test LuaNova.to_number(L, -1) == 1

    LuaNova.safe_script(L, "return s")
    @test LuaNova.to_string(L, -1) == "hello"

    LuaNova.safe_script(L, "return b")
    @test LuaNova.to_boolean(L, -1) == true

    LuaNova.close(L)

    return nothing
end

end
