module TestMultipleReturns

using LuaNova
using Test

function multiple_returns()
    return 1, "hello", true
end

@define_lua_function multiple_returns

@testset "Multiple Returns" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_function(L, "multiple_returns", multiple_returns)

    LuaNova.safe_script(
        L, """
n, s, b = multiple_returns()
assert(n == 1)
assert(s == "hello")
assert(b == true)
return n, s, b
""",
    )

    LuaNova.close(L)

    return nothing
end

end
