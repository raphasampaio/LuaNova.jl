function safe_script(L, str::String)
    return C.luaL_loadstring(L, str) == 1 || C.lua_pcallk(L, 0, Int32(C.LUA_MULTRET), 0, 0, C_NULL) == 1
end

function from_lua(L::Ptr{Cvoid})
    num_args = C.lua_gettop(L)
    
    args = Any[]
    for i in 1:num_args
        lua_typecode = C.lua_type(L, i)
        type_name = unsafe_string(C.lua_typename(L, lua_typecode))
        
        if lua_typecode == C.LUA_TNUMBER
            push!(args, C.lua_tonumber(L, i))
        elseif lua_typecode == C.LUA_TSTRING
            push!(args, unsafe_string(C.lua_tostring(L, i)))
        elseif lua_typecode == C.LUA_TBOOLEAN
            push!(args, C.lua_toboolean(L, i) != 0)
        elseif lua_typecode == C.LUA_TNIL
            push!(args, nothing)
        else
            error("Unsupported Lua type: ", type_name)
        end
    end

    return args
end

function to_lua(L::Ptr{Cvoid}, x::Any)
    error("Unsupported return type: ", typeof(x))
end

function to_lua(L::Ptr{Cvoid}, x::Float64)
    C.lua_pushnumber(L, x)
    return 1
end

function to_lua(L::Ptr{Cvoid}, x::String)
    C.lua_pushstring(L, x)
    return 1
end
