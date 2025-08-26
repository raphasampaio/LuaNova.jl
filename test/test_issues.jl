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

@testset "Issue 15" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    functions = Dict("function1" => function1, "function2" => function2, "function3" => function3)
    @push_lua_struct(L, TestStruct, functions)

    LuaNova.close(L)

    return nothing
end

end
