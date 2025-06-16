# load_script?
function safe_script(L::LuaState, s::String)
    if C.luaL_loadstring(L, s) != 0
        throw(LuaError(L))
    end

    if C.lua_pcallk(L, 0, Int32(C.LUA_MULTRET), 0, 0, C_NULL) != 0
        throw(LuaError(L))
    end

    return nothing
end

function from_lua(L::LuaState)
    num_args = C.lua_gettop(L)

    args = Vector{Any}(undef, num_args)
    for i in 1:num_args
        type_code = C.lua_type(L, i)
        type_name = unsafe_string(C.lua_typename(L, type_code))

        if type_code == C.LUA_TNUMBER
            args[i] = C.lua_tonumber(L, i)
        elseif type_code == C.LUA_TSTRING
            args[i] = unsafe_string(C.lua_tostring(L, i))
        elseif type_code == C.LUA_TBOOLEAN
            args[i] = C.lua_toboolean(L, i) != 0
        elseif type_code == C.LUA_TNIL
            args[i] = nothing
        elseif type_code == C.LUA_TUSERDATA
            C.lua_getmetatable(L, i)
            C.lua_pushstring(L, Base.unsafe_convert(Ptr{Cchar}, pointer("__name")))
            C.lua_rawget(L, -2)
            name = unsafe_string(C.lua_tostring(L, -1))
            C.lua_pop(L, 2)
            args[i] = LuaNova.get_reference(L, i, name)
        else
            error("Unsupported Lua type: ", type_name)
        end
    end

    return args
end

function index(L::Ptr{LuaNova.C.lua_State}, ::Type{T}) where {T}
    str = string(nameof(T))
    ref = LuaNova.get_reference(L, Int32(1), str)
    key = unsafe_string(LuaNova.C.luaL_checklstring(L, 2, C_NULL))

    if hasfield(T, Symbol(key))
        val = getfield(ref, Symbol(key))
        push_to_lua!(L, val)
    else
        # otherwise fall back to normal metatable lookup
        LuaNova.C.luaL_getmetatable(L, to_cstring(str))
        LuaNova.C.lua_pushvalue(L, 2)
        LuaNova.C.lua_gettable(L, -2)
    end

    return 1
end


function from_lua(L::Ptr{LuaNova.C.lua_State}, idx::Cint, fty::Type)
    if fty == Float64
        return LuaNova.C.luaL_checknumber(L, idx)
    elseif fty <: Integer
        return LuaNova.C.luaL_checkinteger(L, idx)
    elseif fty == String
        return unsafe_string(LuaNova.C.luaL_checklstring(L, idx, C_NULL))
    elseif fty == Bool
        return LuaNova.C.lua_toboolean(L, idx) != 0
    else
        # for more complex types you’ve registered, pull the reference back
        # (assumes you used string(nameof(fty)) as the tag)
        tag = to_cstring(string(nameof(fty)))
        return LuaNova.get_reference(L, LuaNova.C.luaL_checkinteger(L, idx), tag)
    end
end


function newindex(L::Ptr{LuaNova.C.lua_State}, ::Type{T}) where {T}
    name = string(nameof(T))
    ref  = LuaNova.get_reference(L, Int32(1), name)
    key  = unsafe_string(LuaNova.C.luaL_checklstring(L, 2, C_NULL))
    sym  = Symbol(key)

    if hasfield(T, sym)
        fty = fieldtype(T, sym)
        val = from_lua(L, Int32(3), fty)
        setfield!(ref, sym, convert(fty, val))
    else
        # fallback: assign into the metatable (so you can still add Lua‐side properties, or let other metamethods catch it)
        LuaNova.C.luaL_getmetatable(L, to_cstring(name))
        LuaNova.C.lua_pushvalue(L, 2)   # key
        LuaNova.C.lua_pushvalue(L, 3)   # new value
        LuaNova.C.lua_settable(L, -3)
    end

    return 0
end

function garbage_collect(L::Ptr{LuaNova.C.lua_State}, ::Type{T}) where {T}
    name = string(nameof(T))
    ud = LuaNova.C.luaL_checkudata(L, 1, to_cstring(name))
    delete!(LuaNova.REGISTRY, Ptr{Cvoid}(ud))
    return 0
end