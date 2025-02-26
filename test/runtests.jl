using LuaCall

# using Aqua
# using Test

# function mysin(L::Ptr{Cvoid})::Cint
#     d = LuaCall.C.lua_tonumber(L, 1)
#     LuaCall.C.lua_pushnumber(L, sin(d))
#     return 1
# end

# function test_capi()
#     L = LuaCall.C.luaL_newstate()
#     LuaCall.C.luaL_openlibs(L)

#     LuaCall.C.lua_pushcfunction(L, @cfunction(mysin, Cint, (Ptr{Cvoid},)))
#     LuaCall.C.lua_setglobal(L, "mysin")

#     LuaCall.C.lua_getglobal(L, "mysin")
#     LuaCall.C.lua_pushnumber(L, 1)

#     if LuaCall.C.lua_pcallk(L, 1, 1, 0, 0, C_NULL) != 0
#         error("Error calling mysin: ", LuaCall.C.lua_tostring(L, -1))
#     end

#     result = LuaCall.C.lua_tonumber(L, -1)

#     @test result ≈ sin(1)

#     LuaCall.C.lua_close(L)

#     return nothing
# end

# function print_lua_argument_types(L::Ptr{Cvoid})::Cint
#     num_args = LuaCall.C.lua_gettop(L)
#     println("Number of arguments on the stack: ", num_args)

#     for i in 1:num_args
#         arg_type = LuaCall.C.lua_type(L, i)
#         type_name = unsafe_string(LuaCall.C.lua_typename(L, arg_type))
#         println("Argument ", i, " type: ", type_name)
#     end

#     return 0
# end

# function test_print_lua_argument_types()
#     L = LuaCall.C.luaL_newstate()
#     LuaCall.C.luaL_openlibs(L)

#     LuaCall.C.lua_pushcfunction(L, @cfunction(print_lua_argument_types, Cint, (Ptr{Cvoid},)))
#     LuaCall.C.lua_setglobal(L, "print_lua_argument_types")

#     LuaCall.safe_script(L, "print_lua_argument_types(1, 'hello', true)")

#     LuaCall.C.lua_close(L)

#     return nothing
# end

# # function call_julia_from_lua(L::Ptr{Cvoid})::Cint
# #     @show args = LuaCall.from_lua(L)

# #     result = julia_function(args...)

# #     return LuaCall.to_lua(L, result)
# # end

# function test_call_julia_from_lua()
#     L = LuaCall.C.luaL_newstate()
#     LuaCall.C.luaL_openlibs(L)

#     @show julia_function_lua

#     # LuaCall.C.lua_pushcfunction(L, @cfunction(julia_function_lua, Cint, (Ptr{Cvoid},)))
#     # LuaCall.C.lua_setglobal(L, "call_julia_from_lua")

#     # LuaCall.safe_script(L, """
#     #     print("Calling julia_function with a number:")
#     #     print(call_julia_from_lua(42.0))

#     #     print("Calling julia_function with a string:")
#     #     print(call_julia_from_lua("A string from Lua"))

#     #     print("Calling julia_function with two numbers:")
#     #     print(call_julia_from_lua(1.0, 2.0))
#     # """)

#     LuaCall.C.lua_close(L)

#     return nothing
# end

# function test_all()
#     # @testset "C API" begin
#     #     test_capi()
#     # end

#     # test_print_lua_argument_types()

#     test_call_julia_from_lua()

#     # L = LuaCall.C.luaL_newstate()

#     # LuaCall.C.luaL_openlibs(L)

#     # LuaCall.C.lua_pushcfunction(L, @cfunction(l_sin, Cint, (Ptr{Cvoid},)))
#     # LuaCall.C.lua_setglobal(L, "mysin")

#     # LuaCall.safe_script(L, "print(mysin(1))")

#     # LuaCall.C.lua_close(L)

#     return nothing
# end

# test_all()

@lua function julia_function(a::Float64)
    println("Called julia_function with a Float64: ", a)
    return a * 2
end

@lua function julia_function(a::String)
    println("Called julia_function with a String: ", a)
    return "Hello, " * a
end

@lua function julia_function(a::Float64, b::Float64)
    println("Called julia_function with two Float64s: ", a, " and ", b)
    return a + b
end

macro push_lua_function(L, lua_function, julia_function)
    return esc(quote
        f = @cfunction($julia_function, Cint, (Ptr{Cvoid},))
        LuaCall.C.lua_pushcfunction($L, f)
        LuaCall.C.lua_setglobal($L, $lua_function)
    end)
end


function test_print_lua_argument_types()
    L = LuaCall.C.luaL_newstate()
    LuaCall.C.luaL_openlibs(L)

    # @show methods(julia_function)

    # f = @cfunction(julia_function, Cint, (Ptr{Cvoid},))
    # LuaCall.C.lua_pushcfunction(L, f)
    # LuaCall.C.lua_setglobal(L, "print_lua_argument_types")

    @push_lua_function(L, "print_lua_argument_types", julia_function)

    LuaCall.safe_script(L, "print_lua_argument_types(1)")
    LuaCall.safe_script(L, "print_lua_argument_types(\"aaa\")")
    LuaCall.safe_script(L, "print_lua_argument_types(1, 2)")

    LuaCall.C.lua_close(L)

    return nothing
end

test_print_lua_argument_types()