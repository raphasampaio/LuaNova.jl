module TestMutableStructs

using LuaNova

# ───– 1) Mutable Point ─────────────────────────────────────────────────────────

mutable struct Point
    x::Float64
    y::Float64
end

function mysum(p::Point, dx::Float64, dy::Float64)
    p.x += dx
    p.y += dy
    return nothing
end

# ───– 4) Lua-callable functions ─────────────────────────────────────────────────

function Point_new(L::Ptr{LuaNova.C.lua_State})::Cint
    args = LuaNova.from_lua(L)
    object = Point(args...)

    ud = LuaNova.C.lua_newuserdatauv(L, Csize_t(0), 0)
    LuaNova.REGISTRY[Ptr{Cvoid}(ud)] = Ref(object)
    LuaNova.C.luaL_setmetatable(L, to_cstring("Point"))

    return 1
end

function Point_tostring(L::Ptr{LuaNova.C.lua_State})::Cint
    p = LuaNova.get_reference(L, Int32(1), "Point")
    LuaNova.C.lua_pushstring(L, to_cstring("Point(" * string(p.x) * ", " * string(p.y) * ")"))
    return 1
end

function Point_index(L::Ptr{LuaNova.C.lua_State})::Cint
    ref = LuaNova.get_reference(L, Int32(1), "Point")
    key = unsafe_string(LuaNova.C.luaL_checklstring(L, 2, C_NULL))
    if key == "x"
        LuaNova.C.lua_pushnumber(L, ref.x)
    elseif key == "y"
        LuaNova.C.lua_pushnumber(L, ref.y)
    else
        # fall back to methods in metatable
        LuaNova.C.luaL_getmetatable(L, to_cstring("Point"))
        LuaNova.C.lua_pushvalue(L, 2)
        LuaNova.C.lua_gettable(L, -2)
    end
    return 1
end

function Point_newindex(L::Ptr{LuaNova.C.lua_State})::Cint
    ref = LuaNova.get_reference(L, Int32(1), "Point")
    key = unsafe_string(LuaNova.C.luaL_checklstring(L, 2, C_NULL))
    val = LuaNova.C.luaL_checknumber(L, 3)
    if key == "x"
        ref.x = val
    elseif key == "y"
        ref.y = val
    else
        LuaNova.C.luaL_argerror(L, 2, to_cstring("invalid field"))
    end
    return 0
end

function Point_sum(L::Ptr{LuaNova.C.lua_State})::Cint
    args = LuaNova.from_lua(L)
    result = mysum(args...)
    return LuaNova.to_lua(L, result)
end

# __gc metamethod to remove from registry when Lua collects the userdata
function Point_gc(L::Ptr{LuaNova.C.lua_State})::Cint
    ud = LuaNova.C.luaL_checkudata(L, 1, to_cstring("Point"))
    delete!(LuaNova.REGISTRY, Ptr{Cvoid}(ud))
    return 0
end

# ───– 5) Turn them into C-functions ─────────────────────────────────────────────

const c_Point_new = @cfunction(Point_new, Cint, (Ptr{LuaNova.C.lua_State},))
const c_Point_tostring = @cfunction(Point_tostring, Cint, (Ptr{LuaNova.C.lua_State},))
const c_Point_index = @cfunction(Point_index, Cint, (Ptr{LuaNova.C.lua_State},))
const c_Point_newindex = @cfunction(Point_newindex, Cint, (Ptr{LuaNova.C.lua_State},))
const c_Point_sum = @cfunction(Point_sum, Cint, (Ptr{LuaNova.C.lua_State},))
const c_Point_gc = @cfunction(Point_gc, Cint, (Ptr{LuaNova.C.lua_State},))

# ───– 6) Register in Lua ───────────────────────────────────────────────────────

L = LuaNova.new_state()
LuaNova.open_libs(L)

LuaNova.C.luaL_newmetatable(L, to_cstring("Point"))

# metamethods
metam = [
    LuaNova.C.luaL_Reg(to_cstring("__gc"), c_Point_gc),
    LuaNova.C.luaL_Reg(to_cstring("__tostring"), c_Point_tostring),
    LuaNova.C.luaL_Reg(to_cstring("__index"), c_Point_index),
    LuaNova.C.luaL_Reg(to_cstring("__newindex"), c_Point_newindex),
    LuaNova.C.luaL_Reg(C_NULL, C_NULL),
]
LuaNova.C.luaL_setfuncs(L, pointer(metam), 0)

# methods
methods = [
    LuaNova.C.luaL_Reg(to_cstring("sum"), c_Point_sum),
    LuaNova.C.luaL_Reg(C_NULL, C_NULL),
]
LuaNova.C.luaL_setfuncs(L, pointer(methods), 0)

# pop metatable
LuaNova.C.lua_pop(L, 1)

# global constructor
LuaNova.C.lua_pushcclosure(L, c_Point_new, 0)
LuaNova.C.lua_setglobal(L, to_cstring("Point"))

# ───– 7) Smoke-test ────────────────────────────────────────────────────────────

LuaNova.safe_script(
    L,
    """
local p = Point(1.2, 3.4)
print(p)        -- Point(1.2, 3.4)
p.x = 9.8
print(p)        -- Point(9.8, 3.4)
p:sum(10, 20)
print(p)        -- Point(19.8, 23.4)
""",
)

LuaNova.close(L)

end # module
