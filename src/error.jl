struct LuaError <: Exception
    msg::String

    function LuaError(L::LuaState)
        return new("LuaError: " * to_string(L, -1))
    end
end

function Base.showerror(io::IO, e::LuaError)
    return print(io, "LuaError: ", e.msg)
end
