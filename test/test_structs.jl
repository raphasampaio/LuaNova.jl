module TestStructs

using LuaNova
using Test

# # mutable struct Person
# #     name::String
# #     age::Int
# # end

# # function l_newPerson(L)
# #     name = unsafe_string(LuaNova.C.luaL_checklstring(L, 1))  # Get name argument from Lua
# #     age = LuaNova.C.luaL_checkinteger(L, 2)  # Get age argument from Lua

# #     # Create a new Julia Person object
# #     person = Person(name, age)

# #     # Create a new userdata in Lua to store the Person object
# #     userdata = LuaNova.C.unsafe_newuserdata(L, Person)
# #     unsafe_store!(userdata, person)

# #     # Set the metatable for the Person object in Lua
# #     LuaNova.C.luaL_getmetatable(L, "PersonMetaTable")
# #     LuaNova.C.lua_setmetatable(L, -2)

# #     return 1  # Return the userdata (Person instance) to Lua
# # end

# # function myobject_new(L)

# # 	*reinterpret_cast<MyObject**>(lua_newuserdata(L, sizeof(MyObject*))) = new MyObject(x);
# # 	luaL_setmetatable(L, LUA_MYOBJECT);
# # 	return 1;
# # }

# struct MyObject
#     x::Float64
# end

# const LUA_MYOBJECT = "MyObject"

# function myobject_new(L::Ptr{Cvoid})::Cint
#     @show x = LuaNova.C.luaL_checknumber(L, 1)
#     @show object = MyObject(x)

#     # @show ptr = LuaNova.C.lua_newuserdatauv(L, sizeof(MyObject), 1)

#     # unsafe_store!(ptr, object)

#     # @show ptr = LuaNova.C.lua_touserdata(L, -1)    

#     # ptr = Base.unsafe_convert(Ptr{MyObject}, LuaNova.C.lua_touserdata(L, -1))

#     ud = lua_newuserdatauv(L, Csize_t(sizeof(MyObject)), 0)

#     unsafe_store!(Ptr{MyObject}(ud), p)

#     luaL_setmetatable(L, cstr(LUA_MYOBJECT))
#     return ud
# end

# @testset "Structs" begin
#     L = LuaNova.new_state()
#     LuaNova.open_libs(L)

# 	LuaNova.C.lua_register(L, LUA_MYOBJECT, @cfunction(myobject_new, Cint, (Ptr{Cvoid},)))
# 	LuaNova.C.luaL_newmetatable(L, LUA_MYOBJECT)
# 	# LuaNova.C.lua_pushcfunction(L, myobject_delete); lua_setfield(L, -2, "__gc");
# 	# LuaNova.C.lua_pushvalue(L, -1); lua_setfield(L, -2, "__index");
# 	# LuaNova.C.lua_pushcfunction(L, myobject_set); lua_setfield(L, -2, "set");
# 	# LuaNova.C.lua_pushcfunction(L, myobject_get); lua_setfield(L, -2, "get");
# 	LuaNova.C.lua_pop(L, 1)

#     # #    // Create the metatable for MyClass
#     # LuaNova.C.luaL_newmetatable(L, "MyClass")

#     # # // Set the methods in the metatable
#     # lua_pushcfunction(L, lua_MyClass_say_hello);
#     # lua_setfield(L, -2, "say_hello");

#     # lua_pushcfunction(L, lua_MyClass_add);
#     # lua_setfield(L, -2, "add");

#     # # // Set the metatable's __gc method to destroy the object when it is garbage collected
#     # lua_pushcfunction(L, [](LuaNova.C.lua_State* L) -> int {
#     #     MyClass* obj = *(MyClass**)luaL_checkudata(L, 1, "MyClass");
#     #     delete obj;
#     #     return 0;
#     # });
#     # lua_setfield(L, -2, "__gc");

#     # # // Pop the metatable, it's on the top of the stack now
#     # lua_pop(L, 1);

#     # # // Register the constructor function
#     # lua_register(L, "MyClass_new", lua_MyClass_new);

#     # #   /* newclass = {} */
#     # LuaNova.C.lua_createtable(L, 0, 0)
#     # lib_id = LuaNova.C.lua_gettop(L)

#     # #   /* metatable = {} */
#     # LuaNova.C.luaL_newmetatable(L, "Foo")
#     # meta_id = LuaNova.C.lua_gettop(L)
#     # LuaNova.C.luaL_setfuncs(L, _meta, 0)

#     # #   /* metatable.__index = _methods */
#     # LuaNova.C.luaL_newlib(L, _methods)
#     # LuaNova.C.lua_setfield(L, meta_id, "__index")

#     # #   /* metatable.__metatable = _meta */
#     # LuaNova.C.luaL_newlib(L, _meta)
#     # LuaNova.C.lua_setfield(L, meta_id, "__metatable")

#     # #   /* class.__metatable = metatable */
#     # LuaNova.C.lua_setmetatable(L, lib_id)

#     # #   /* _G["Foo"] = newclass */
#     # LuaNova.C.lua_setglobal(L, "Foo")

#     # # Create the metatable for the Person class
#     # LuaNova.C.luaL_newmetatable(L, "PersonMetaTable")

#     # # Set the __index field to allow methods to be called
#     # LuaNova.C.lua_pushvalue(L, -1)  # Duplicate the metatable
#     # LuaNova.C.lua_setfield(L, -2, "__index")

#     # # Register the methods (functions)
#     # lua_pushcfunction(L, l_person_greet)
#     # lua_setfield(L, -2, "greet")

#     # lua_pushcfunction(L, l_person_getName)
#     # lua_setfield(L, -2, "getName")

#     # lua_pushcfunction(L, l_person_getAge)
#     # lua_setfield(L, -2, "getAge")

#     #     # Register the constructor function globally as 'newPerson'
#     #     LuaNova.C.lua_register(L, "newPerson", @cfunction(l_newPerson, Cint, (Ptr{Cvoid},)))

#     LuaNova.safe_script(
#         L, """
# obj = MyObject(42)
# """)

#     # LuaNova.C.luaL_newmetatable(L, "MyType")
#     # LuaNova.C.lua_pushstring(L, "__index")
#     # LuaNova.C.lua_pushvalue(L, -2)
#     # LuaNova.C.lua_settable(L, -3)

#     LuaNova.close(L)

#     return nothing
# end

# (1) Define your Julia struct
struct Point
    x::Float64
    y::Float64
end

# convenience to turn a Julia string into a C‐string pointer
cstr(s::AbstractString) = Base.unsafe_convert(Ptr{Cchar}, pointer(s))

# (2a) push helper: allocates userdata + sets its metatable
function push_Point(L::Ptr{LuaNova.C.lua_State}, p::Point)
    # allocate userdata of exactly sizeof(Point) bytes
    ud = LuaNova.C.lua_newuserdatauv(L, Csize_t(sizeof(Point)), 0)
    # copy the Julia struct into that memory
    unsafe_store!(Ptr{Point}(ud), p)
    # set its metatable so Lua knows its type
    LuaNova.C.luaL_setmetatable(L, cstr("Point"))
    return ud
end

# (2b) check helper: verifies userdata + retrieves your struct
function check_Point(L::Ptr{LuaNova.C.lua_State}, idx::Cint)::Point
    ud = LuaNova.C.luaL_checkudata(L, idx, cstr("Point"))
    return unsafe_load(Ptr{Point}(ud))
end

# (3a) constructor: Point(x,y)
function Point_new(L::Ptr{LuaNova.C.lua_State})::Cint
    # get args from Lua stack
    x = LuaNova.C.luaL_checknumber(L, 1)
    y = LuaNova.C.luaL_checknumber(L, 2)
    # construct Julia object and push
    push_Point(L, Point(x, y))
    return 1            # number of return values
end

# (3b) __tostring metamethod
function Point_tostring(L::Ptr{LuaNova.C.lua_State})::Cint
    p = check_Point(L, Int32(1))
    # push a Lua string
    LuaNova.C.lua_pushstring(L, cstr("Pointaaaa(" * string(p.x) * ", " * string(p.y) * ")"))
    return 1
end

# (3c) __index metamethod for field access
function Point_index(L::Ptr{LuaNova.C.lua_State})::Cint
    p = check_Point(L, Int32(1))
    # get the key as a Julia string
    key = unsafe_string(LuaNova.C.luaL_checklstring(L, 2, C_NULL))
    if key == "x"
        LuaNova.C.lua_pushnumber(L, p.x)
    elseif key == "y"
        LuaNova.C.lua_pushnumber(L, p.y)
    else
        LuaNova.C.lua_pushnil(L)
    end
    return 1
end

# (3d) __newindex metamethod for field assignment
function Point_newindex(L::Ptr{LuaNova.C.lua_State})::Cint
    # we need a mutable backing—we require a Ptr{Point} so we can write into it
    ud = LuaNova.C.luaL_checkudata(L, 1, cstr("Point"))
    pptr = Ptr{Point}(ud)
    key = unsafe_string(LuaNova.C.luaL_checklstring(L, 2, C_NULL))
    val = LuaNova.C.luaL_checknumber(L, 3)
    if key == "x"
        unsafe_store!(pptr, Point(val, unsafe_load(pptr).y))
    elseif key == "y"
        unsafe_store!(pptr, Point(unsafe_load(pptr).x, val))
    else
        # arg error: invalid field
        LuaNova.C.luaL_argerror(L, 2, cstr("invalid field"))
    end
    return 0
end

# turn our Julia functions into C‐callable pointers
const c_Point_new = @cfunction(Point_new, Cint, (Ptr{LuaNova.C.lua_State},))
const c_Point_tostring = @cfunction(Point_tostring, Cint, (Ptr{LuaNova.C.lua_State},))
const c_Point_index = @cfunction(Point_index, Cint, (Ptr{LuaNova.C.lua_State},))
const c_Point_newindex = @cfunction(Point_newindex, Cint, (Ptr{LuaNova.C.lua_State},))

L = LuaNova.new_state()
LuaNova.open_libs(L)

LuaNova.C.luaL_newmetatable(L, cstr("Point"))

# register the metamethods
regs = [
    LuaNova.C.luaL_Reg(cstr("__tostring"), c_Point_tostring),
    LuaNova.C.luaL_Reg(cstr("__index"), c_Point_index),
    LuaNova.C.luaL_Reg(cstr("__newindex"), c_Point_newindex),
    # end with a sentinel
    LuaNova.C.luaL_Reg(C_NULL, C_NULL),
]
LuaNova.C.luaL_setfuncs(L, pointer(regs), 0)

# pop the metatable off the stack
LuaNova.C.lua_pop(L, 1)

# register the global constructor Point()
LuaNova.C.lua_pushcclosure(L, c_Point_new, 0)
LuaNova.C.lua_setglobal(L, cstr("Point"))

LuaNova.safe_script(
    L, """
local p = Point(1.2, 3.4)
print(p)
print(p.x, p.y)
p.x = 9.8
""")

LuaNova.close(L)

end