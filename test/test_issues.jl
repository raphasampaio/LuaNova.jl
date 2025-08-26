module TestIssues

using EnumX
using LuaNova
using Test

@enumx Fruit Apple Banana

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
    
    # Register the Fruit enum type with a metatable BEFORE calling create_apple
    fruit_name = LuaNova.to_string(typeof(Fruit.Apple))  # Use the same function the library uses
    LuaNova.new_metatable(L, fruit_name)
    LuaNova.C.lua_pushstring(L, LuaNova.to_cstring("__name"))
    LuaNova.C.lua_pushstring(L, LuaNova.to_cstring(fruit_name))
    LuaNova.C.lua_rawset(L, -3)
    LuaNova.C.lua_pop(L, 1)

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