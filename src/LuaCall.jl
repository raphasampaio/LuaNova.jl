module LuaCall

export from_lua, to_lua, @lua, @push_lua_function

include("capi.jl")
import .C

include("state.jl")

macro lua(func_def)
    function_name = func_def.args[1].args[1]

    return esc(quote
        $func_def

        function $function_name(L::Ptr{Cvoid})::Cint
            args = LuaCall.from_lua(L)
            result = $function_name(args...)
            return LuaCall.to_lua(L, result)
        end
    end)
end

macro push_lua_function(L, lua_function, julia_function)
    return esc(quote
        f = @cfunction($julia_function, Cint, (Ptr{Cvoid},))
        LuaCall.C.lua_pushcfunction($L, f)
        LuaCall.C.lua_setglobal($L, $lua_function)
    end)
end

end
