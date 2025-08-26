module TestIssues

using EnumX
using LuaNova
using Test

@enumx Fruit Apple Banana
@define_lua_enumx Fruit

create_apple() = Fruit.Apple
@define_lua_function create_apple

function julia_typeof(x::Any)
    return string(typeof(x))
end
@define_lua_function julia_typeof

@testset "Issue X" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_function(L, "create_apple", create_apple)
    @push_lua_function(L, "julia_typeof", julia_typeof)
    
    # Register the Fruit enum metatable using the generated function
    register_Fruit_metatable(L)

    LuaNova.safe_script(
        L,
        """
apple = create_apple()
result = julia_typeof(apple)
assert(result == "Main.TestIssues.Fruit.T")
    """,
    )

    LuaNova.close(L)

    return nothing
end

end