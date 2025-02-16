using LuaCall

using Aqua
using Test

include("aqua.jl")
include("macro.jl")

function test_simple_example()
    @show L = LuaCall.C.luaL_newstate()

    LuaCall.C.luaL_openlibs(L)

    @show LuaCall.C.luaL_loadstring(L, "print(1 + 10)")
    
    @show LuaCall.C.lua_pcallk(L, 0, -1, 0, 0, C_NULL)

    # lua_pcall(L, 0, LUA_MULTRET, 0))
    # lua_pcall(L,n,r,f)
    # (L, (n), (r), (f), 0, NULL)

    # @show LuaCall.C.lua_type(L, Cint(-1))

    # @show LuaCall.C.lua_tostring(L, Cint(-1))

    LuaCall.C.lua_close(L)
    
    return nothing
end


# function myobject_new(L::Ptr{Cvoid})::Cint
#     x = LuaCall.C.luaL_checknumber(L, 1)
#     p = LuaCall.C.lua_newuserdata(L, sizeof(Cvoid))
#     LuaCall.C.luaL_setmetatable(L, "MyObject")
#     return 1
# end

function l_sin(L::Ptr{Cvoid})::Cint
    d = LuaCall.C.lua_tonumber(L, 1)
    LuaCall.C.lua_pushnumber(L, sin(d))
    return 1
end

function test_classes()
    @show L = LuaCall.C.luaL_newstate()

    LuaCall.C.luaL_openlibs(L)

    ptr = @cfunction(l_sin, Cint, (Ptr{Cvoid},))

    LuaCall.C.lua_pushcfunction(L, ptr)
    LuaCall.C.lua_setglobal(L, "mysin")

    @show safe_script(L, "print(mysin(10))")

    # LuaCall.C.lua_createtable(L, 0, 0)
    # LuaCall.C.lua_pushcfunction(L, ptr)
    # # LuaCall.C.lua_setfield(l, -2, "new")
    # # LuaCall.C.lua_setglobal(l, "MyObject")

    # # LuaCall.C.lua_register(L, "MyObject", ptr)

    # # lua_register(L, LUA_MYOBJECT, myobject_new);
	# # luaL_newmetatable(L, LUA_MYOBJECT);
	# # lua_pushcfunction(L, myobject_delete); lua_setfield(L, -2, "__gc");
	# # lua_pushvalue(L, -1); lua_setfield(L, -2, "__index");
	# # lua_pushcfunction(L, myobject_set); lua_setfield(L, -2, "set");
	# # lua_pushcfunction(L, myobject_get); lua_setfield(L, -2, "get");
	# # lua_pop(L, 1);


    LuaCall.C.lua_close(L)
end

function myadd(x::Float64, y::Float64)
    return x + y
end

function test_macro()
    lua_register(
        :add,
        Float64,
        [Float64, Float64],
        myadd
    )

    @show L = LuaCall.C.luaL_newstate()
    LuaCall.C.luaL_openlibs(L)

    @show safe_script(L, "print(\"Hello, world!\")")

    finalize_lua_registration(L, :add)

    @show safe_script(L, "print(add_Float64_Float64(1, 2))")

    # @show registered_func = LuaCall.CACHE[:add][Tuple{Float64, Float64}]
    # result = registered_func(1.0, 2.5)
    # @show result  # 3.5

#     registered_func = REGISTERED_FUNCTIONS[:add]
# result = registered_func(1.0, 2.5)
# @show result  # 3.5
    
    # finalize_lua_registration(:add)

    # @register_lua_function L greet "lua_greet"

    LuaCall.C.lua_close(L)
end

function test_all()
    # @testset "Aqua.jl" begin
    #     test_aqua()
    # end

    # test_simple_example()

    # test_classes()

    test_macro()

    return nothing
end

test_all()
