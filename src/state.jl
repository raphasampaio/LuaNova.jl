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
            @show name = unsafe_string(C.lua_tostring(L, -1))
            C.lua_pop(L, 2)

            converter = get(USERDATA_CONVERTERS, name, nothing)
            if converter === nothing
                error("Unsupported userdata type: ", name)
            end
            args[i] = converter(L, Int32(i))
        else
            error("Unsupported Lua type: ", type_name)
        end
    end

    return args
end

function to_lua(L::LuaState, x::Any)
    throw(ArgumentError("Unsupported type: $(typeof(x))"))
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
