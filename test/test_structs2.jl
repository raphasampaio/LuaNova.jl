module TestMutableStructs

using LuaNova
using Test

# ─── 1) Immutable, isbits Point ────────────────────────────────────────────────

# Why immutable? Julia only lets you unsafe_store!/unsafe_load “inline” for isbits types (immutable structs whose fields are all bits). Once you switch to a mutable struct, Julia boxes the object and the inline store/load stops working as you observed. If you truly need a mutable struct you’d have to instead store a Ref{Point} inside the userdata (and manage GC rooting), pull out the Ref via unsafe_load, then do r[].x = … / r[].x += … inside your metamethods. That’s doable, but far more plumbing.

struct Point
    x::Float64
    y::Float64
end

# ─── 2a) push helper: allocate userdata and copy the struct in ───────────────

function push_Point(L::Ptr{LuaNova.C.lua_State}, p::Point)
    # exactly sizeof(Point)==16 bytes for two Float64
    ud = LuaNova.C.lua_newuserdatauv(L, Csize_t(sizeof(Point)), 0)
    unsafe_store!(Ptr{Point}(ud), p)           # copy p into that memory
    LuaNova.C.luaL_setmetatable(L, to_cstring("Point"))
    return ud
end

# ─── 2b) check helper: verify type + load it back out ─────────────────────────

function check_Point(L::Ptr{LuaNova.C.lua_State}, idx::Cint)::Point
    ud = LuaNova.C.luaL_checkudata(L, idx, to_cstring("Point"))
    return unsafe_load(Ptr{Point}(ud))
end

# ─── 3a) constructor: Point(x,y) ───────────────────────────────────────────────

function Point_new(L::Ptr{LuaNova.C.lua_State})::Cint
    x = LuaNova.C.luaL_checknumber(L, 1)
    y = LuaNova.C.luaL_checknumber(L, 2)
    push_Point(L, Point(x, y))
    return 1
end

# ─── 3b) __tostring metamethod ────────────────────────────────────────────────

function Point_tostring(L::Ptr{LuaNova.C.lua_State})::Cint
    p = check_Point(L, Int32(1))
    LuaNova.C.lua_pushstring(L, to_cstring("Point(" * string(p.x) * ", " * string(p.y) * ")"))
    return 1
end

# ─── 3c) __index metamethod for reading .x and .y (and falling back to methods) ─

function Point_index(L::Ptr{LuaNova.C.lua_State})::Cint
    p   = check_Point(L, Int32(1))
    key = unsafe_string(LuaNova.C.luaL_checklstring(L, 2, C_NULL))
    if key == "x"
        LuaNova.C.lua_pushnumber(L, p.x)
    elseif key == "y"
        LuaNova.C.lua_pushnumber(L, p.y)
    else
        # fall back to any methods in the metatable
        LuaNova.C.luaL_getmetatable(L, to_cstring("Point"))
        LuaNova.C.lua_pushvalue(L, 2)
        LuaNova.C.lua_gettable(L, -2)
    end
    return 1
end

# ─── 3d) __newindex metamethod for writing .x and .y ──────────────────────────

function Point_newindex(L::Ptr{LuaNova.C.lua_State})::Cint
    ud   = LuaNova.C.luaL_checkudata(L, 1, to_cstring("Point"))
    pptr = Ptr{Point}(ud)
    key  = unsafe_string(LuaNova.C.luaL_checklstring(L, 2, C_NULL))
    val  = LuaNova.C.luaL_checknumber(L, 3)

    old = unsafe_load(pptr)
    if key == "x"
        unsafe_store!(pptr, Point(val, old.y))
    elseif key == "y"
        unsafe_store!(pptr, Point(old.x, val))
    else
        LuaNova.C.luaL_argerror(L, 2, to_cstring("invalid field"))
    end

    return 0
end

# ─── 3e) sum method: add (dx,dy) and write back ────────────────────────────────

function Point_sum(L::Ptr{LuaNova.C.lua_State})::Cint
    ud   = LuaNova.C.luaL_checkudata(L, 1, to_cstring("Point"))
    pptr = Ptr{Point}(ud)

    dx = LuaNova.C.luaL_checknumber(L, 2)
    dy = LuaNova.C.luaL_checknumber(L, 3)

    old = unsafe_load(pptr)
    unsafe_store!(pptr, Point(old.x + dx, old.y + dy))

    return 0
end

# ─── 4) make C‐callable function pointers ───────────────────────────────────────

const c_Point_new      = @cfunction(Point_new,      Cint, (Ptr{LuaNova.C.lua_State},))
const c_Point_tostring = @cfunction(Point_tostring, Cint, (Ptr{LuaNova.C.lua_State},))
const c_Point_index    = @cfunction(Point_index,    Cint, (Ptr{LuaNova.C.lua_State},))
const c_Point_newindex = @cfunction(Point_newindex, Cint, (Ptr{LuaNova.C.lua_State},))
const c_Point_sum      = @cfunction(Point_sum,      Cint, (Ptr{LuaNova.C.lua_State},))

# ─── 5) hook it all up in Lua ─────────────────────────────────────────────────

L = LuaNova.new_state()
LuaNova.open_libs(L)

# create the Point metatable
LuaNova.C.luaL_newmetatable(L, to_cstring("Point"))

# metamethods
regs = [
    LuaNova.C.luaL_Reg(to_cstring("__tostring"), c_Point_tostring),
    LuaNova.C.luaL_Reg(to_cstring("__index"),     c_Point_index),
    LuaNova.C.luaL_Reg(to_cstring("__newindex"),  c_Point_newindex),
    LuaNova.C.luaL_Reg(C_NULL,              C_NULL),
]
LuaNova.C.luaL_setfuncs(L, pointer(regs), 0)

# normal methods (available as p:sum)
methods = [
    LuaNova.C.luaL_Reg(to_cstring("sum"), c_Point_sum),
    LuaNova.C.luaL_Reg(C_NULL,      C_NULL),
]
LuaNova.C.luaL_setfuncs(L, pointer(methods), 0)

# pop the metatable
LuaNova.C.lua_pop(L, 1)

# register the constructor Point()
LuaNova.C.lua_pushcclosure(L, c_Point_new, 0)
LuaNova.C.lua_setglobal(L, to_cstring("Point"))

# ─── 6) smoke–test it ─────────────────────────────────────────────────────────

LuaNova.safe_script(L, """
local p = Point(1.2, 3.4)
print(p)         -- Point(1.2, 3.4)
p.x = 9.8
print(p)         -- Point(9.8, 3.4)
p:sum(10, 20)
print(p)         -- Point(19.8, 23.4)
""")

LuaNova.close(L)

end # module
