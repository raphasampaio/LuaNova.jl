module TestVarargs

using LuaNova
using Test

function sum_all(numbers...)
    return sum(numbers)
end
@define_lua_function sum_all

function concatenate_strings(strings...)
    return join(strings, "")
end
@define_lua_function concatenate_strings

function count_args(args...)
    return length(args)
end
@define_lua_function count_args

@testset "Varargs Functions" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_function(L, "sum_all", sum_all)
    @push_lua_function(L, "concatenate_strings", concatenate_strings)
    @push_lua_function(L, "count_args", count_args)

    # Test sum_all with multiple numbers
    LuaNova.get_global(L, "sum_all")
    LuaNova.push_to_lua!(L, 1.0)
    LuaNova.push_to_lua!(L, 2.0)
    LuaNova.push_to_lua!(L, 3.0)
    LuaNova.push_to_lua!(L, 4.0)
    LuaNova.protected_call(L, 4)
    result = LuaNova.to_number(L, -1)
    @test result == 10.0

    # Test concatenate_strings with multiple strings
    LuaNova.get_global(L, "concatenate_strings")
    LuaNova.push_to_lua!(L, "Hello")
    LuaNova.push_to_lua!(L, " ")
    LuaNova.push_to_lua!(L, "World")
    LuaNova.push_to_lua!(L, "!")
    LuaNova.protected_call(L, 4)
    result = LuaNova.to_string(L, -1)
    @test result == "Hello World!"

    # Test count_args with varying number of arguments
    LuaNova.get_global(L, "count_args")
    LuaNova.push_to_lua!(L, 1)
    LuaNova.push_to_lua!(L, 2)
    LuaNova.push_to_lua!(L, 3)
    LuaNova.protected_call(L, 3)
    result = LuaNova.to_number(L, -1)
    @test result == 3

    # Test with no arguments
    LuaNova.get_global(L, "count_args")
    LuaNova.protected_call(L, 0)
    result = LuaNova.to_number(L, -1)
    @test result == 0

    LuaNova.close(L)

    return nothing
end

end