macro define_lua_function(function_name)
    return esc(quote
        function $function_name(L::Ptr{Cvoid})::Cint
            args = Lua.from_lua(L)
            result = $function_name(args...)
            return Lua.to_lua(L, result)
        end
    end)
end

macro push_lua_function(L, lua_function, julia_function)
    return esc(quote
        f = @cfunction($julia_function, Cint, (Ptr{Cvoid},))
        Lua.C.lua_pushcfunction($L, f)
        Lua.C.lua_setglobal($L, $lua_function)
    end)
end
