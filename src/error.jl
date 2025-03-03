struct LuaError <: Exception
    msg::String
end

function Base.showerror(io::IO, e::LuaError)
    return print(io, "LuaError: ", e.msg)
end
