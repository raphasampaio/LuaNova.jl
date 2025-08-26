module TestIssues

using LuaNova
using Test

mutable struct TestStruct end
@define_lua_struct TestStruct

function1(::TestStruct) = 1
@define_lua_function function1

function2(::TestStruct) = 2
@define_lua_function function2

function3(::TestStruct) = 3
@define_lua_function function3

macro push_lua_struct_splat(L::Symbol, julia_struct::Symbol, container)
    return esc(quote
        @push_lua_struct($L, $julia_struct, $container...)
    end)
end

@testset "Issue X" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    functions = ("function1", function1, "function2", function2, "function3", function3)
    @push_lua_struct_splat(L, TestStruct, functions)

    LuaNova.close(L)

    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    functions = ["function1", function1, "function2", function2, "function3", function3]
    @push_lua_struct_splat(L2, TestStruct, functions)

    LuaNova.close(L2)

    return nothing
end

end
