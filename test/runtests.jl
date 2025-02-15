using LuaCall

using Aqua
using Test

include("aqua.jl")

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

macro register_lua_function(lua_state, julia_function, lua_function_name)
    # Get function signature and argument types
    @show func_info = Base.unwrap_unionall(typeof(eval(julia_function)).name.wrapper)
    @show arg_types = func_info.parameters[1:end-1]  # Remove return type

    # Generate a wrapper function name
    @show wrapper_name = Symbol(:lua_wrapper_, julia_function)

    # # Argument conversion logic
    # conversion_exprs = []
    # for (i, arg_type) in enumerate(arg_types)
    #     push!(conversion_exprs, quote
    #         local arg_$i
    #         if $arg_type == Float64
    #             arg_$i = lua_tonumber(L, $i)
    #         elseif $arg_type == String
    #             arg_$i = lua_tolstring(L, $i)
    #         else
    #             error("Unsupported Lua to Julia type conversion for argument $i")
    #         end
    #     end)
    # end

    # # Create call expression dynamically
    # call_expr = Expr(:call, julia_function, [Symbol(:arg_, i) for i in 1:length(arg_types)]...)

    # # Push return value logic
    # return_expr = quote
    #     local result = $call_expr
    #     if result isa Float64
    #         lua_pushnumber(L, result)
    #     elseif result isa String
    #         lua_pushstring(L, result)
    #     else
    #         error("Unsupported return type")
    #     end
    # end

    # quote
    #     function $wrapper_name(L::Ptr{Cvoid})::Cint
    #         local num_args = lua_gettop(L)
    #         if num_args != $(length(arg_types))
    #             error("Incorrect number of arguments. Expected $(length(arg_types)), got ", num_args)
    #         end
            
    #         $(Expr(:block, conversion_exprs...))

    #         $return_expr

    #         return 1  # Returning one value to Lua
    #     end

    #     # Convert Julia function to C function pointer
    #     f_ptr = @cfunction($wrapper_name, Cint, (Ptr{Cvoid},))

    #     # Push function and register it in Lua
    #     lua_pushcfunction($lua_state, f_ptr)
    #     lua_setglobal($lua_state, $lua_function_name)
    # end
end

function add(a::Float64, b::Float64)
    return a + b
end

function greet(name::String)
    return "Hello, " * name
end

function test_macro()
    @show L = LuaCall.C.luaL_newstate()

    LuaCall.C.luaL_openlibs(L)

    @register_lua_function L add "lua_add"
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
