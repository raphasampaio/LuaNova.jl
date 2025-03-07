struct LuaError <: Exception
    msg::String

    function LuaError(msg::String)
        return new("LuaError: " * msg)
    end

    function LuaError(L::LuaState)
        return new(to_string(L, -1))
    end
end

function Base.showerror(io::IO, e::LuaError)
    return print(io, "LuaError: ", e.msg)
end
