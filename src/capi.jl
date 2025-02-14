module C

using Lua_jll
export Lua_jll

function luaL_newstate()
    return @ccall liblua.luaL_newstate()::Ptr{Cvoid}
end

function luaL_openlibs(L::Ptr{Cvoid})
    @ccall liblua.luaL_openlibs(L::Ptr{Cvoid})::Cvoid
    return nothing
end

function luaL_loadfilex(L::Ptr{Cvoid}, filename::String, mode::String)
    return @ccall liblua.luaL_loadfilex(L::Ptr{Cvoid}, filename::Cstring, mode::Cstring)::Cint
end

function luaL_loadstring(L::Ptr{Cvoid}, s::String)
    return @ccall liblua.luaL_loadstring(L::Ptr{Cvoid}, s::Cstring)::Cint
end

function lua_close(L::Ptr{Cvoid})
    @ccall liblua.lua_close(L::Ptr{Cvoid})::Cvoid
    return nothing
end

end