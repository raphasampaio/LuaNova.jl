module TestIssues

using EnumX
using LuaNova
using Test

@enumx Fruit Apple Banana

create_apple() = Fruit.Apple
@define_lua_function create_apple

function julia_typeof(x::Any)
    @show typeof(x)
    return nothing
end
@define_lua_function julia_typeof

@testset "Issue X" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_function(L, "create_apple", create_apple)
    @push_lua_function(L, "julia_typeof", julia_typeof)

    LuaNova.safe_script(
        L,
        """
apple = create_apple()
print(apple)
print(julia_typeof(apple))
    """,
    )

    LuaNova.close(L)

    return nothing
end

end