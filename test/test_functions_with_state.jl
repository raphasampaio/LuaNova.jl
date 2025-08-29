module TestFunctionsWithState

using LuaNova
using Test

function state_aware_sum(L::LuaState, a::Float64, b::Float64)
    @test L isa LuaState
    return a + b
end

function state_aware_concat(L::LuaState, a::String, b::String)
    @test L isa LuaState
    return a * b
end

function state_aware_boolean_op(L::LuaState, a::Bool, b::Bool)
    @test L isa LuaState
    return a && b
end

function state_aware_multiple_returns(L::LuaState, x::Float64)
    @test L isa LuaState
    return x, x^2, x^3
end

function state_aware_no_args(L::LuaState)
    @test L isa LuaState
    return 42.0
end

@define_lua_function_with_state state_aware_sum
@define_lua_function_with_state state_aware_concat
@define_lua_function_with_state state_aware_boolean_op
@define_lua_function_with_state state_aware_multiple_returns
@define_lua_function_with_state state_aware_no_args

@testset "Functions with state" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    # Test numeric function with state
    @push_lua_function(L, "state_sum", state_aware_sum)
    LuaNova.get_global(L, "state_sum")
    LuaNova.push_to_lua!(L, 1.0)
    LuaNova.push_to_lua!(L, 2.0)
    LuaNova.protected_call(L, 2)
    result = LuaNova.to_number(L, -1)
    @test result == 3.0

    # Test string function with state
    @push_lua_function(L, "state_concat", state_aware_concat)
    LuaNova.get_global(L, "state_concat")
    LuaNova.push_to_lua!(L, "hello")
    LuaNova.push_to_lua!(L, "world")
    LuaNova.protected_call(L, 2)
    result = LuaNova.to_string(L, -1)
    @test result == "helloworld"

    # Test boolean function with state
    @push_lua_function(L, "state_bool", state_aware_boolean_op)
    LuaNova.get_global(L, "state_bool")
    LuaNova.push_to_lua!(L, true)
    LuaNova.push_to_lua!(L, false)
    LuaNova.protected_call(L, 2)
    result = LuaNova.to_boolean(L, -1)
    @test result == false

    # Clear stack from previous tests
    LuaNova.C.lua_settop(L, 0)

    # Test multiple return values with state
    @push_lua_function(L, "state_multiple", state_aware_multiple_returns)
    LuaNova.get_global(L, "state_multiple")
    LuaNova.push_to_lua!(L, 2.0)
    LuaNova.protected_call(L, 1)
    # Should return 3 values: 2.0, 4.0, 8.0
    @test LuaNova.C.lua_gettop(L) == 3
    result1 = LuaNova.to_number(L, -3)
    result2 = LuaNova.to_number(L, -2)
    result3 = LuaNova.to_number(L, -1)
    @test result1 == 2.0
    @test result2 == 4.0
    @test result3 == 8.0

    # Test function with no arguments (only state)
    @push_lua_function(L, "state_no_args", state_aware_no_args)
    LuaNova.get_global(L, "state_no_args")
    LuaNova.protected_call(L, 0)
    result = LuaNova.to_number(L, -1)
    @test result == 42.0

    LuaNova.close(L)

    return nothing
end

end
