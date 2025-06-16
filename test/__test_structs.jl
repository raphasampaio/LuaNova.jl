module TestStructs

using LuaNova
using Test

struct Point
    x::Float64
    y::Float64
end

# (2a) push helper: allocates userdata + sets its metatable
function push_Point(L::Ptr{LuaNova.C.lua_State}, p::Point)
    # allocate userdata of exactly sizeof(Point) bytes
    ud = LuaNova.C.lua_newuserdatauv(L, Csize_t(sizeof(Point)), 0)
    # copy the Julia struct into that memory
    unsafe_store!(Ptr{Point}(ud), p)
    # set its metatable so Lua knows its type
    LuaNova.C.luaL_setmetatable(L, to_cstring("Point"))
    return ud
end

# (2b) check helper: verifies userdata + retrieves your struct
function check_Point(L::Ptr{LuaNova.C.lua_State}, idx::Cint)::Point
    ud = LuaNova.C.luaL_checkudata(L, idx, to_cstring("Point"))
    return unsafe_load(Ptr{Point}(ud))
end

# (3a) constructor: Point(x,y)
function Point_new(L::Ptr{LuaNova.C.lua_State})::Cint
    # get args from Lua stack
    x = LuaNova.C.luaL_checknumber(L, 1)
    y = LuaNova.C.luaL_checknumber(L, 2)
    # construct Julia object and push
    push_Point(L, Point(x, y))
    return 1
end

# (3b) __tostring metamethod
function Point_tostring(L::Ptr{LuaNova.C.lua_State})::Cint
    p = check_Point(L, Int32(1))
    LuaNova.C.lua_pushstring(L, to_cstring("Pointaaaa(" * string(p.x) * ", " * string(p.y) * ")"))
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
        LuaNova.C.luaL_getmetatable(L, to_cstring("Point"))  # push mt
        LuaNova.C.lua_pushvalue(L, 2)                  # push key
        LuaNova.C.lua_gettable(L, -2)                  # push mt[key] or nil
    end
    return 1
end

# (3d) __newindex metamethod for field assignment
function Point_newindex(L::Ptr{LuaNova.C.lua_State})::Cint
    # we need a mutable backing—we require a Ptr{Point} so we can write into it
    ud = LuaNova.C.luaL_checkudata(L, 1, to_cstring("Point"))
    pptr = Ptr{Point}(ud)
    key = unsafe_string(LuaNova.C.luaL_checklstring(L, 2, C_NULL))
    val = LuaNova.C.luaL_checknumber(L, 3)
    if key == "x"
        unsafe_store!(pptr, Point(val, unsafe_load(pptr).y))
    elseif key == "y"
        unsafe_store!(pptr, Point(unsafe_load(pptr).x, val))
    else
        LuaNova.C.luaL_argerror(L, 2, to_cstring("invalid field"))
    end
    return 0
end

# function Point_sum(L::Ptr{LuaNova.C.lua_State})::Cint
#     # 1st arg is the userdata; we just type-check it
#     _ = check_Point(L, Int32(1))
#     # next two args are numbers
#     @show a = LuaNova.C.luaL_checknumber(L, 2)
#     @show b = LuaNova.C.luaL_checknumber(L, 3)
#     # push their sum
#     LuaNova.C.lua_pushnumber(L, a + b)
#     return 1
# end

function Point_sum(L::Ptr{LuaNova.C.lua_State})::Cint
    # 1) get the raw userdata pointer for mutation
    ud = LuaNova.C.luaL_checkudata(L, 1, to_cstring("Point"))
    pptr = Ptr{Point}(ud)

    # 2) read the deltas
    dx = LuaNova.C.luaL_checknumber(L, 2)
    dy = LuaNova.C.luaL_checknumber(L, 3)

    # 3) load, modify, and write back
    old = unsafe_load(pptr)
    unsafe_store!(pptr, Point(old.x + dx, old.y + dy))

    # 4) no values returned
    return 0
end

# turn our Julia functions into C‐callable pointers
const c_Point_new = @cfunction(Point_new, Cint, (Ptr{LuaNova.C.lua_State},))
const c_Point_tostring = @cfunction(Point_tostring, Cint, (Ptr{LuaNova.C.lua_State},))
const c_Point_index = @cfunction(Point_index, Cint, (Ptr{LuaNova.C.lua_State},))
const c_Point_newindex = @cfunction(Point_newindex, Cint, (Ptr{LuaNova.C.lua_State},))
const c_Point_sum = @cfunction(Point_sum, Cint, (Ptr{LuaNova.C.lua_State},))

L = LuaNova.new_state()
LuaNova.open_libs(L)

LuaNova.C.luaL_newmetatable(L, to_cstring("Point"))

# register the metamethods
regs = [
    LuaNova.C.luaL_Reg(to_cstring("__tostring"), c_Point_tostring),
    LuaNova.C.luaL_Reg(to_cstring("__index"), c_Point_index),
    LuaNova.C.luaL_Reg(to_cstring("__newindex"), c_Point_newindex),
    # end with a sentinel
    LuaNova.C.luaL_Reg(C_NULL, C_NULL),
]
LuaNova.C.luaL_setfuncs(L, pointer(regs), 0)

methods = [
    LuaNova.C.luaL_Reg(to_cstring("sum"), c_Point_sum),
    LuaNova.C.luaL_Reg(C_NULL, C_NULL),
]
LuaNova.C.luaL_setfuncs(L, pointer(methods), 0)

# pop the metatable off the stack
LuaNova.C.lua_pop(L, 1)

# register the global constructor Point()
LuaNova.C.lua_pushcclosure(L, c_Point_new, 0)
LuaNova.C.lua_setglobal(L, to_cstring("Point"))

LuaNova.safe_script(
    L, """
local p = Point(1.2, 3.4)
print(p)
p.x = 9.8
print(p)
p:sum(10, 20)
print(p)
""")

LuaNova.close(L)

end
