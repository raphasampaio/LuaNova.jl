function new_state()
    return C.luaL_newstate()
end

function open_libs(L::LuaState)
    C.luaL_openlibs(L)
    return nothing
end

function close(L::LuaState)
    C.lua_close(L)
    return nothing
end

function protected_call(L::LuaState, nargs::Integer)
    if C.lua_pcallk(L, nargs, Int32(C.LUA_MULTRET), 0, 0, C_NULL) != 0
        throw(LuaError(L))
    end
    return nothing
end

function to_string(L::LuaState, idx::Integer)
    return unsafe_string(C.lua_tostring(L, idx))
end

function to_number(L::LuaState, idx::Integer)
    return C.lua_tonumber(L, idx)
end

function to_boolean(L::LuaState, idx::Integer)
    return C.lua_toboolean(L, idx) != 0
end

function push_to_lua!(L::LuaState, x::Real)
    C.lua_pushnumber(L, x)
    return nothing
end

function push_to_lua!(L::LuaState, x::Integer)
    C.lua_pushnumber(L, x)
    return nothing
end

function push_to_lua!(L::LuaState, x::String)
    C.lua_pushstring(L, x)
    return nothing
end

function push_to_lua!(L::LuaState, x::Bool)
    C.lua_pushboolean(L, x)
    return nothing
end

function push_to_lua!(L::LuaState, ::Nothing)
    C.lua_pushnil(L)
    return nothing
end

function push_to_lua!(L::LuaState, x::T) where {T}
    struct_string = to_string(T)
    userdata = new_userdata(L, 0)
    REGISTRY[userdata] = Ref(x)
    set_metatable(L, struct_string)
    return nothing
end

function get_global(L::LuaState, name::String)
    C.lua_getglobal(L, name)
    return nothing
end

function set_global(L::LuaState, name::String)
    C.lua_setglobal(L, to_cstring(name))
    return nothing
end

function new_table(L::LuaState)
    C.lua_createtable(L, 0, 0)
    return nothing
end

function set_table(L::LuaState, idx::Integer)
    C.lua_settable(L, idx)
    return nothing
end

function get_table(L::LuaState, idx::Integer)
    C.lua_gettable(L, idx)
    return nothing
end

function arith(L::LuaState, op::String)
    C.lua_arith(L, op)
    return nothing
end

function load_string(L::LuaState, s::String)
    if C.luaL_loadstring(L, s) != 0
        throw(LuaError(L))
    end
    return nothing
end

function new_userdata(L::LuaState, size::Integer)::Ptr{Cvoid}
    return C.lua_newuserdatauv(L, Csize_t(size), 0)
end

function new_metatable(L::LuaState, name::String)
    return C.luaL_newmetatable(L, to_cstring(name))
end

function set_metatable(L::LuaState, idx::Integer)
    C.lua_setmetatable(L, idx)
    return nothing
end

function set_metatable(L::LuaState, name::String)
    C.luaL_setmetatable(L, to_cstring(name))
    return nothing
end

function get_metatable(L::LuaState, idx::Integer)
    return C.lua_getmetatable(L, idx)
end

function get_metatable(L::LuaState, name::String)
    return C.luaL_getmetatable(L, to_cstring(name))
end

function to_userdata(L::LuaState, idx::Integer)
    return C.lua_touserdata(L, idx)
end

function to_userdata(L::LuaState, idx::Integer, ::Type{T}) where {T}
    return get_reference(L, idx, to_string(T))
end

function lua_check_userdata(L::LuaState, idx::Integer, name::String)
    return C.luaL_checkudata(L, Int32(idx), to_cstring(name))
end

function create_register(name::String, f::Ptr{Cvoid})
    return C.luaL_Reg(to_cstring(name), f)
end

function create_null_register()
    return C.luaL_Reg(C_NULL, C_NULL)
end

function set_functions(L::LuaState, methods::Vector{C.luaL_Reg})
    C.luaL_setfuncs(L, pointer(methods), 0)
    return nothing
end

function lua_pop!(L::LuaState, n::Integer)
    C.lua_pop(L, n)
    return nothing
end

function push_cfunction(L::LuaState, cfunction::Union{Ptr{Cvoid}, Ptr{Nothing}})
    C.lua_pushcfunction(L, cfunction)
    return nothing
end

function is_table(L::LuaState, idx::Integer)
    return C.lua_type(L, idx) == C.LUA_TTABLE
end

function raw_len(L::LuaState, idx::Integer)
    return C.lua_rawlen(L, idx)
end

function lua_table_to_vector(L::LuaState, idx::Integer)
    if !is_table(L, idx)
        error("Value at index $idx is not a table")
    end
    
    table_length = Int(raw_len(L, idx))
    result = Vector{Any}(undef, table_length)
    
    for i in 1:table_length
        push_to_lua!(L, i)
        get_table(L, idx > 0 ? idx : idx - 1)
        
        type_code = C.lua_type(L, -1)
        
        if type_code == C.LUA_TNUMBER
            result[i] = C.lua_tonumber(L, -1)
        elseif type_code == C.LUA_TSTRING
            result[i] = unsafe_string(C.lua_tostring(L, -1))
        elseif type_code == C.LUA_TBOOLEAN
            result[i] = C.lua_toboolean(L, -1) != 0
        elseif type_code == C.LUA_TNIL
            result[i] = nothing
        elseif type_code == C.LUA_TTABLE
            result[i] = lua_table_to_dict(L, -1)
        else
            type_name = unsafe_string(C.lua_typename(L, type_code))
            result[i] = "Unsupported type: $type_name"
        end
        
        lua_pop!(L, 1)
    end
    
    return result
end

function lua_table_to_dict(L::LuaState, idx::Integer)
    if !is_table(L, idx)
        error("Value at index $idx is not a table")
    end
    
    result = Dict{Any, Any}()
    
    C.lua_pushnil(L)
    
    while C.lua_next(L, idx > 0 ? idx : idx - 1) != 0
        key_type = C.lua_type(L, -2)
        value_type = C.lua_type(L, -1)
        
        key = if key_type == C.LUA_TNUMBER
            C.lua_tonumber(L, -2)
        elseif key_type == C.LUA_TSTRING
            unsafe_string(C.lua_tostring(L, -2))
        elseif key_type == C.LUA_TBOOLEAN
            C.lua_toboolean(L, -2) != 0
        else
            key_type_name = unsafe_string(C.lua_typename(L, key_type))
            "Unsupported key type: $key_type_name"
        end
        
        value = if value_type == C.LUA_TNUMBER
            C.lua_tonumber(L, -1)
        elseif value_type == C.LUA_TSTRING
            unsafe_string(C.lua_tostring(L, -1))
        elseif value_type == C.LUA_TBOOLEAN
            C.lua_toboolean(L, -1) != 0
        elseif value_type == C.LUA_TNIL
            nothing
        elseif value_type == C.LUA_TTABLE
            lua_table_to_dict(L, -1)
        else
            value_type_name = unsafe_string(C.lua_typename(L, value_type))
            "Unsupported value type: $value_type_name"
        end
        
        result[key] = value
        lua_pop!(L, 1)
    end
    
    return result
end
