module TestIssues

using LuaNova
using Test

@testset "Issue X" begin
    mutable struct Struct end
    @define_lua_struct Struct

    function function1(::Struct)
        return 1
    end
    @define_lua_function function1

    function function2(::Struct)
        return 2
    end
    @define_lua_function function2

    function function3(::Struct)
        return 3
    end
    @define_lua_function function3

    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    functions = ("function1", function1, "function2", function2, "function3", function3)

    @push_lua_struct(
        L,
        Struct,
        functions,
    )

    LuaNova.close(L)

    return nothing
end

end
