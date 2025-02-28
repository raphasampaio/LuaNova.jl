function safe_script(L::LuaState, str::String)
    return C.luaL_loadstring(L, str) == 1 || C.lua_pcallk(L, 0, Int32(C.LUA_MULTRET), 0, 0, C_NULL) == 1
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
        else
            error("Unsupported Lua type: ", type_name)
        end
    end

    return args
end

function to_lua(L::LuaState, x::Any)
    error("Unsupported return type: ", typeof(x))
    return nothing
end

function to_lua(L::LuaState, x::Real)
    push_number(L, x)
    return 1
end

function to_lua(L::LuaState, x::String)
    push_string(L, x)
    return 1
end

function to_lua(L::LuaState, x::Bool)
    push_boolean(L, x)
    return 1
end
