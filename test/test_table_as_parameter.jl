module TestTableAsParameter

using LuaNova
using Test

function foo(table)
    @show typeof(table)
    return nothing
end
@define_lua_function foo

@testset "Table as parameter" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_function(L, "foo", foo)

    LuaNova.safe_script(L, "foo({})")

    LuaNova.close(L)

    return nothing
end

end
