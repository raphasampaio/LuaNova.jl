module C

using Lua_jll
export Lua_jll

const LUA_TNONE = -1
const LUA_TNIL = 0
const LUA_TBOOLEAN = 1
const LUA_TLIGHTUSERDATA = 2
const LUA_TNUMBER = 3
const LUA_TSTRING = 4
const LUA_TTABLE = 5
const LUA_TFUNCTION = 6
const LUA_TUSERDATA = 7
const LUA_TTHREAD = 8
const LUA_NUMTYPES = 9

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

function luaL_dostring(L::Ptr{Cvoid}, str::String)
    return @ccall liblua.luaL_dostring(L::Ptr{Cvoid}, str::Cstring)::Cint
end

function luaL_loadstring(L::Ptr{Cvoid}, s::String)
    return @ccall liblua.luaL_loadstring(L::Ptr{Cvoid}, s::Cstring)::Cint
end

function lua_pcall(L::Ptr{Cvoid}, nargs::Cint, nresults::Cint, msgh::Cint)
    return @ccall liblua.lua_pcall(L::Ptr{Cvoid}, nargs::Cint, nresults::Cint, msgh::Cint)::Cint
end

function lua_type(L::Ptr{Cvoid}, index::Cint)
    return @ccall liblua.lua_type(L::Ptr{Cvoid}, index::Cint)::Cint
end

function lua_tostring(L::Ptr{Cvoid}, index::Cint)
    return @ccall liblua.lua_tostring(L::Ptr{Cvoid}, index::Cint)::Cstring
end

function lua_pop(L::Ptr{Cvoid}, n::Cint)
    return @ccall liblua.lua_pop(L::Ptr{Cvoid}, n::Cint)::Cvoid
end

function lua_close(L::Ptr{Cvoid})
    @ccall liblua.lua_close(L::Ptr{Cvoid})::Cvoid
    return nothing
end

end