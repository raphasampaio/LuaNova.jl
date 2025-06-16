module C

using Lua_jll
export Lua_jll

const UINT_MAX = typemax(Int64)

const lua_Integer = Clonglong

const lua_Number = Cdouble

mutable struct lua_State end

function luaL_checkversion_(L, ver, sz)
    @ccall liblua.luaL_checkversion_(L::Ptr{lua_State}, ver::lua_Number, sz::Csize_t)::Cvoid
end

function luaL_loadfilex(L, filename, mode)
    @ccall liblua.luaL_loadfilex(L::Ptr{lua_State}, filename::Ptr{Cchar}, mode::Ptr{Cchar})::Cint
end

function lua_createtable(L, narr, nrec)
    @ccall liblua.lua_createtable(L::Ptr{lua_State}, narr::Cint, nrec::Cint)::Cvoid
end

# typedef int ( * lua_CFunction ) ( lua_State * L )
const lua_CFunction = Ptr{Cvoid}

struct luaL_Reg
    name::Ptr{Cchar}
    func::lua_CFunction
end

function luaL_setfuncs(L, l, nup)
    @ccall liblua.luaL_setfuncs(L::Ptr{lua_State}, l::Ptr{luaL_Reg}, nup::Cint)::Cvoid
end

function luaL_argerror(L, arg, extramsg)
    @ccall liblua.luaL_argerror(L::Ptr{lua_State}, arg::Cint, extramsg::Ptr{Cchar})::Cint
end

function luaL_typeerror(L, arg, tname)
    @ccall liblua.luaL_typeerror(L::Ptr{lua_State}, arg::Cint, tname::Ptr{Cchar})::Cint
end

function luaL_checklstring(L, arg, l)
    @ccall liblua.luaL_checklstring(L::Ptr{lua_State}, arg::Cint, l::Ptr{Csize_t})::Ptr{Cchar}
end

function luaL_optlstring(L, arg, def, l)
    @ccall liblua.luaL_optlstring(L::Ptr{lua_State}, arg::Cint, def::Ptr{Cchar}, l::Ptr{Csize_t})::Ptr{Cchar}
end

function lua_typename(L, tp)
    @ccall liblua.lua_typename(L::Ptr{lua_State}, tp::Cint)::Ptr{Cchar}
end

function lua_type(L, idx)
    @ccall liblua.lua_type(L::Ptr{lua_State}, idx::Cint)::Cint
end

const lua_KContext = Cptrdiff_t

# typedef int ( * lua_KFunction ) ( lua_State * L , int status , lua_KContext ctx )
const lua_KFunction = Ptr{Cvoid}

function lua_pcallk(L, nargs, nresults, errfunc, ctx, k)
    @ccall liblua.lua_pcallk(L::Ptr{lua_State}, nargs::Cint, nresults::Cint, errfunc::Cint, ctx::lua_KContext, k::lua_KFunction)::Cint
end

function luaL_loadstring(L, s)
    @ccall liblua.luaL_loadstring(L::Ptr{lua_State}, s::Ptr{Cchar})::Cint
end

function lua_getfield(L, idx, k)
    @ccall liblua.lua_getfield(L::Ptr{lua_State}, idx::Cint, k::Ptr{Cchar})::Cint
end

function luaL_loadbufferx(L, buff, sz, name, mode)
    @ccall liblua.luaL_loadbufferx(L::Ptr{lua_State}, buff::Ptr{Cchar}, sz::Csize_t, name::Ptr{Cchar}, mode::Ptr{Cchar})::Cint
end

const lua_Unsigned = Culonglong

function lua_pushnil(L)
    @ccall liblua.lua_pushnil(L::Ptr{lua_State})::Cvoid
end

struct var"union (unnamed at C:\\Users\\rsampaio\\.julia\\artifacts\\38e43295d4913c3d9e6b8baf05f545a89880759c\\include\\lauxlib.h:196:3)"
    data::NTuple{1024, UInt8}
end

function Base.getproperty(x::Ptr{var"union (unnamed at C:\\Users\\rsampaio\\.julia\\artifacts\\38e43295d4913c3d9e6b8baf05f545a89880759c\\include\\lauxlib.h:196:3)"}, f::Symbol)
    f === :n && return Ptr{lua_Number}(x + 0)
    f === :u && return Ptr{Cdouble}(x + 0)
    f === :s && return Ptr{Ptr{Cvoid}}(x + 0)
    f === :i && return Ptr{lua_Integer}(x + 0)
    f === :l && return Ptr{Clong}(x + 0)
    f === :b && return Ptr{NTuple{1024, Cchar}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"union (unnamed at C:\\Users\\rsampaio\\.julia\\artifacts\\38e43295d4913c3d9e6b8baf05f545a89880759c\\include\\lauxlib.h:196:3)", f::Symbol)
    r = Ref{var"union (unnamed at C:\\Users\\rsampaio\\.julia\\artifacts\\38e43295d4913c3d9e6b8baf05f545a89880759c\\include\\lauxlib.h:196:3)"}(x)
    ptr = Base.unsafe_convert(Ptr{var"union (unnamed at C:\\Users\\rsampaio\\.julia\\artifacts\\38e43295d4913c3d9e6b8baf05f545a89880759c\\include\\lauxlib.h:196:3)"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"union (unnamed at C:\\Users\\rsampaio\\.julia\\artifacts\\38e43295d4913c3d9e6b8baf05f545a89880759c\\include\\lauxlib.h:196:3)"}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

struct luaL_Buffer
    data::NTuple{1056, UInt8}
end

function Base.getproperty(x::Ptr{luaL_Buffer}, f::Symbol)
    f === :b && return Ptr{Ptr{Cchar}}(x + 0)
    f === :size && return Ptr{Csize_t}(x + 8)
    f === :n && return Ptr{Csize_t}(x + 16)
    f === :L && return Ptr{Ptr{lua_State}}(x + 24)
    f === :init && return Ptr{var"union (unnamed at C:\\Users\\rsampaio\\.julia\\artifacts\\38e43295d4913c3d9e6b8baf05f545a89880759c\\include\\lauxlib.h:196:3)"}(x + 32)
    return getfield(x, f)
end

function Base.getproperty(x::luaL_Buffer, f::Symbol)
    r = Ref{luaL_Buffer}(x)
    ptr = Base.unsafe_convert(Ptr{luaL_Buffer}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{luaL_Buffer}, f::Symbol, v)
    return unsafe_store!(getproperty(x, f), v)
end

function luaL_prepbuffsize(B, sz)
    @ccall liblua.luaL_prepbuffsize(B::Ptr{luaL_Buffer}, sz::Csize_t)::Ptr{Cchar}
end

function luaL_getmetafield(L, obj, e)
    @ccall liblua.luaL_getmetafield(L::Ptr{lua_State}, obj::Cint, e::Ptr{Cchar})::Cint
end

function luaL_callmeta(L, obj, e)
    @ccall liblua.luaL_callmeta(L::Ptr{lua_State}, obj::Cint, e::Ptr{Cchar})::Cint
end

function luaL_tolstring(L, idx, len)
    @ccall liblua.luaL_tolstring(L::Ptr{lua_State}, idx::Cint, len::Ptr{Csize_t})::Ptr{Cchar}
end

function luaL_checknumber(L, arg)
    @ccall liblua.luaL_checknumber(L::Ptr{lua_State}, arg::Cint)::lua_Number
end

function luaL_optnumber(L, arg, def)
    @ccall liblua.luaL_optnumber(L::Ptr{lua_State}, arg::Cint, def::lua_Number)::lua_Number
end

function luaL_checkinteger(L, arg)
    @ccall liblua.luaL_checkinteger(L::Ptr{lua_State}, arg::Cint)::lua_Integer
end

function luaL_optinteger(L, arg, def)
    @ccall liblua.luaL_optinteger(L::Ptr{lua_State}, arg::Cint, def::lua_Integer)::lua_Integer
end

function luaL_checkstack(L, sz, msg)
    @ccall liblua.luaL_checkstack(L::Ptr{lua_State}, sz::Cint, msg::Ptr{Cchar})::Cvoid
end

function luaL_checktype(L, arg, t)
    @ccall liblua.luaL_checktype(L::Ptr{lua_State}, arg::Cint, t::Cint)::Cvoid
end

function luaL_checkany(L, arg)
    @ccall liblua.luaL_checkany(L::Ptr{lua_State}, arg::Cint)::Cvoid
end

function luaL_newmetatable(L, tname)
    @ccall liblua.luaL_newmetatable(L::Ptr{lua_State}, tname::Ptr{Cchar})::Cint
end

function luaL_setmetatable(L, tname)
    @ccall liblua.luaL_setmetatable(L::Ptr{lua_State}, tname::Ptr{Cchar})::Cvoid
end

function luaL_testudata(L, ud, tname)
    @ccall liblua.luaL_testudata(L::Ptr{lua_State}, ud::Cint, tname::Ptr{Cchar})::Ptr{Cvoid}
end

function luaL_checkudata(L, ud, tname)
    @ccall liblua.luaL_checkudata(L::Ptr{lua_State}, ud::Cint, tname::Ptr{Cchar})::Ptr{Cvoid}
end

function luaL_where(L, lvl)
    @ccall liblua.luaL_where(L::Ptr{lua_State}, lvl::Cint)::Cvoid
end

function luaL_checkoption(L, arg, def, lst)
    @ccall liblua.luaL_checkoption(L::Ptr{lua_State}, arg::Cint, def::Ptr{Cchar}, lst::Ptr{Ptr{Cchar}})::Cint
end

function luaL_fileresult(L, stat, fname)
    @ccall liblua.luaL_fileresult(L::Ptr{lua_State}, stat::Cint, fname::Ptr{Cchar})::Cint
end

function luaL_execresult(L, stat)
    @ccall liblua.luaL_execresult(L::Ptr{lua_State}, stat::Cint)::Cint
end

function luaL_ref(L, t)
    @ccall liblua.luaL_ref(L::Ptr{lua_State}, t::Cint)::Cint
end

function luaL_unref(L, t, ref)
    @ccall liblua.luaL_unref(L::Ptr{lua_State}, t::Cint, ref::Cint)::Cvoid
end

function luaL_newstate()
    @ccall liblua.luaL_newstate()::Ptr{lua_State}
end

function luaL_len(L, idx)
    @ccall liblua.luaL_len(L::Ptr{lua_State}, idx::Cint)::lua_Integer
end

function luaL_addgsub(b, s, p, r)
    @ccall liblua.luaL_addgsub(b::Ptr{luaL_Buffer}, s::Ptr{Cchar}, p::Ptr{Cchar}, r::Ptr{Cchar})::Cvoid
end

function luaL_gsub(L, s, p, r)
    @ccall liblua.luaL_gsub(L::Ptr{lua_State}, s::Ptr{Cchar}, p::Ptr{Cchar}, r::Ptr{Cchar})::Ptr{Cchar}
end

function luaL_getsubtable(L, idx, fname)
    @ccall liblua.luaL_getsubtable(L::Ptr{lua_State}, idx::Cint, fname::Ptr{Cchar})::Cint
end

function luaL_traceback(L, L1, msg, level)
    @ccall liblua.luaL_traceback(L::Ptr{lua_State}, L1::Ptr{lua_State}, msg::Ptr{Cchar}, level::Cint)::Cvoid
end

function luaL_requiref(L, modname, openf, glb)
    @ccall liblua.luaL_requiref(L::Ptr{lua_State}, modname::Ptr{Cchar}, openf::lua_CFunction, glb::Cint)::Cvoid
end

function luaL_buffinit(L, B)
    @ccall liblua.luaL_buffinit(L::Ptr{lua_State}, B::Ptr{luaL_Buffer})::Cvoid
end

function luaL_addlstring(B, s, l)
    @ccall liblua.luaL_addlstring(B::Ptr{luaL_Buffer}, s::Ptr{Cchar}, l::Csize_t)::Cvoid
end

function luaL_addstring(B, s)
    @ccall liblua.luaL_addstring(B::Ptr{luaL_Buffer}, s::Ptr{Cchar})::Cvoid
end

function luaL_addvalue(B)
    @ccall liblua.luaL_addvalue(B::Ptr{luaL_Buffer})::Cvoid
end

function luaL_pushresult(B)
    @ccall liblua.luaL_pushresult(B::Ptr{luaL_Buffer})::Cvoid
end

function luaL_pushresultsize(B, sz)
    @ccall liblua.luaL_pushresultsize(B::Ptr{luaL_Buffer}, sz::Csize_t)::Cvoid
end

function luaL_buffinitsize(L, B, sz)
    @ccall liblua.luaL_buffinitsize(L::Ptr{lua_State}, B::Ptr{luaL_Buffer}, sz::Csize_t)::Ptr{Cchar}
end

struct luaL_Stream
    f::Ptr{Libc.FILE}
    closef::lua_CFunction
end

function lua_callk(L, nargs, nresults, ctx, k)
    @ccall liblua.lua_callk(L::Ptr{lua_State}, nargs::Cint, nresults::Cint, ctx::lua_KContext, k::lua_KFunction)::Cvoid
end

function lua_yieldk(L, nresults, ctx, k)
    @ccall liblua.lua_yieldk(L::Ptr{lua_State}, nresults::Cint, ctx::lua_KContext, k::lua_KFunction)::Cint
end

function lua_tonumberx(L, idx, isnum)
    @ccall liblua.lua_tonumberx(L::Ptr{lua_State}, idx::Cint, isnum::Ptr{Cint})::lua_Number
end

function lua_tointegerx(L, idx, isnum)
    @ccall liblua.lua_tointegerx(L::Ptr{lua_State}, idx::Cint, isnum::Ptr{Cint})::lua_Integer
end

function lua_settop(L, idx)
    @ccall liblua.lua_settop(L::Ptr{lua_State}, idx::Cint)::Cvoid
end

function lua_pushcclosure(L, fn, n)
    @ccall liblua.lua_pushcclosure(L::Ptr{lua_State}, fn::lua_CFunction, n::Cint)::Cvoid
end

function lua_setglobal(L, name)
    @ccall liblua.lua_setglobal(L::Ptr{lua_State}, name::Ptr{Cchar})::Cvoid
end

function lua_pushstring(L, s)
    @ccall liblua.lua_pushstring(L::Ptr{lua_State}, s::Ptr{Cchar})::Ptr{Cchar}
end

function lua_rawgeti(L, idx, n)
    @ccall liblua.lua_rawgeti(L::Ptr{lua_State}, idx::Cint, n::lua_Integer)::Cint
end

function lua_tolstring(L, idx, len)
    @ccall liblua.lua_tolstring(L::Ptr{lua_State}, idx::Cint, len::Ptr{Csize_t})::Ptr{Cchar}
end

function lua_rotate(L, idx, n)
    @ccall liblua.lua_rotate(L::Ptr{lua_State}, idx::Cint, n::Cint)::Cvoid
end

function lua_copy(L, fromidx, toidx)
    @ccall liblua.lua_copy(L::Ptr{lua_State}, fromidx::Cint, toidx::Cint)::Cvoid
end

function lua_newuserdatauv(L, sz, nuvalue)
    @ccall liblua.lua_newuserdatauv(L::Ptr{lua_State}, sz::Csize_t, nuvalue::Cint)::Ptr{Cvoid}
end

function lua_getiuservalue(L, idx, n)
    @ccall liblua.lua_getiuservalue(L::Ptr{lua_State}, idx::Cint, n::Cint)::Cint
end

function lua_setiuservalue(L, idx, n)
    @ccall liblua.lua_setiuservalue(L::Ptr{lua_State}, idx::Cint, n::Cint)::Cint
end

# typedef const char * ( * lua_Reader ) ( lua_State * L , void * ud , size_t * sz )
const lua_Reader = Ptr{Cvoid}

# typedef int ( * lua_Writer ) ( lua_State * L , const void * p , size_t sz , void * ud )
const lua_Writer = Ptr{Cvoid}

# typedef void * ( * lua_Alloc ) ( void * ud , void * ptr , size_t osize , size_t nsize )
const lua_Alloc = Ptr{Cvoid}

# typedef void ( * lua_WarnFunction ) ( void * ud , const char * msg , int tocont )
const lua_WarnFunction = Ptr{Cvoid}

mutable struct CallInfo end

struct lua_Debug
    event::Cint
    name::Ptr{Cchar}
    namewhat::Ptr{Cchar}
    what::Ptr{Cchar}
    source::Ptr{Cchar}
    srclen::Csize_t
    currentline::Cint
    linedefined::Cint
    lastlinedefined::Cint
    nups::Cuchar
    nparams::Cuchar
    isvararg::Cchar
    istailcall::Cchar
    ftransfer::Cushort
    ntransfer::Cushort
    short_src::NTuple{60, Cchar}
    i_ci::Ptr{CallInfo}
end

# typedef void ( * lua_Hook ) ( lua_State * L , lua_Debug * ar )
const lua_Hook = Ptr{Cvoid}

function lua_newstate(f, ud)
    @ccall liblua.lua_newstate(f::lua_Alloc, ud::Ptr{Cvoid})::Ptr{lua_State}
end

function lua_close(L)
    @ccall liblua.lua_close(L::Ptr{lua_State})::Cvoid
end

function lua_newthread(L)
    @ccall liblua.lua_newthread(L::Ptr{lua_State})::Ptr{lua_State}
end

function lua_closethread(L, from)
    @ccall liblua.lua_closethread(L::Ptr{lua_State}, from::Ptr{lua_State})::Cint
end

function lua_resetthread(L)
    @ccall liblua.lua_resetthread(L::Ptr{lua_State})::Cint
end

function lua_atpanic(L, panicf)
    @ccall liblua.lua_atpanic(L::Ptr{lua_State}, panicf::lua_CFunction)::lua_CFunction
end

function lua_version(L)
    @ccall liblua.lua_version(L::Ptr{lua_State})::lua_Number
end

function lua_absindex(L, idx)
    @ccall liblua.lua_absindex(L::Ptr{lua_State}, idx::Cint)::Cint
end

function lua_gettop(L)
    @ccall liblua.lua_gettop(L::Ptr{lua_State})::Cint
end

function lua_pushvalue(L, idx)
    @ccall liblua.lua_pushvalue(L::Ptr{lua_State}, idx::Cint)::Cvoid
end

function lua_checkstack(L, n)
    @ccall liblua.lua_checkstack(L::Ptr{lua_State}, n::Cint)::Cint
end

function lua_xmove(from, to, n)
    @ccall liblua.lua_xmove(from::Ptr{lua_State}, to::Ptr{lua_State}, n::Cint)::Cvoid
end

function lua_isnumber(L, idx)
    @ccall liblua.lua_isnumber(L::Ptr{lua_State}, idx::Cint)::Cint
end

function lua_isstring(L, idx)
    @ccall liblua.lua_isstring(L::Ptr{lua_State}, idx::Cint)::Cint
end

function lua_iscfunction(L, idx)
    @ccall liblua.lua_iscfunction(L::Ptr{lua_State}, idx::Cint)::Cint
end

function lua_isinteger(L, idx)
    @ccall liblua.lua_isinteger(L::Ptr{lua_State}, idx::Cint)::Cint
end

function lua_isuserdata(L, idx)
    @ccall liblua.lua_isuserdata(L::Ptr{lua_State}, idx::Cint)::Cint
end

function lua_toboolean(L, idx)
    @ccall liblua.lua_toboolean(L::Ptr{lua_State}, idx::Cint)::Cint
end

function lua_rawlen(L, idx)
    @ccall liblua.lua_rawlen(L::Ptr{lua_State}, idx::Cint)::lua_Unsigned
end

function lua_tocfunction(L, idx)
    @ccall liblua.lua_tocfunction(L::Ptr{lua_State}, idx::Cint)::lua_CFunction
end

function lua_touserdata(L, idx)
    @ccall liblua.lua_touserdata(L::Ptr{lua_State}, idx::Cint)::Ptr{Cvoid}
end

function lua_tothread(L, idx)
    @ccall liblua.lua_tothread(L::Ptr{lua_State}, idx::Cint)::Ptr{lua_State}
end

function lua_topointer(L, idx)
    @ccall liblua.lua_topointer(L::Ptr{lua_State}, idx::Cint)::Ptr{Cvoid}
end

function lua_arith(L, op)
    @ccall liblua.lua_arith(L::Ptr{lua_State}, op::Cint)::Cvoid
end

function lua_rawequal(L, idx1, idx2)
    @ccall liblua.lua_rawequal(L::Ptr{lua_State}, idx1::Cint, idx2::Cint)::Cint
end

function lua_compare(L, idx1, idx2, op)
    @ccall liblua.lua_compare(L::Ptr{lua_State}, idx1::Cint, idx2::Cint, op::Cint)::Cint
end

function lua_pushnumber(L, n)
    @ccall liblua.lua_pushnumber(L::Ptr{lua_State}, n::lua_Number)::Cvoid
end

function lua_pushinteger(L, n)
    @ccall liblua.lua_pushinteger(L::Ptr{lua_State}, n::lua_Integer)::Cvoid
end

function lua_pushlstring(L, s, len)
    @ccall liblua.lua_pushlstring(L::Ptr{lua_State}, s::Ptr{Cchar}, len::Csize_t)::Ptr{Cchar}
end

function lua_pushboolean(L, b)
    @ccall liblua.lua_pushboolean(L::Ptr{lua_State}, b::Cint)::Cvoid
end

function lua_pushlightuserdata(L, p)
    @ccall liblua.lua_pushlightuserdata(L::Ptr{lua_State}, p::Ptr{Cvoid})::Cvoid
end

function lua_pushthread(L)
    @ccall liblua.lua_pushthread(L::Ptr{lua_State})::Cint
end

function lua_getglobal(L, name)
    @ccall liblua.lua_getglobal(L::Ptr{lua_State}, name::Ptr{Cchar})::Cint
end

function lua_gettable(L, idx)
    @ccall liblua.lua_gettable(L::Ptr{lua_State}, idx::Cint)::Cint
end

function lua_geti(L, idx, n)
    @ccall liblua.lua_geti(L::Ptr{lua_State}, idx::Cint, n::lua_Integer)::Cint
end

function lua_rawget(L, idx)
    @ccall liblua.lua_rawget(L::Ptr{lua_State}, idx::Cint)::Cint
end

function lua_rawgetp(L, idx, p)
    @ccall liblua.lua_rawgetp(L::Ptr{lua_State}, idx::Cint, p::Ptr{Cvoid})::Cint
end

function lua_getmetatable(L, objindex)
    @ccall liblua.lua_getmetatable(L::Ptr{lua_State}, objindex::Cint)::Cint
end

function lua_settable(L, idx)
    @ccall liblua.lua_settable(L::Ptr{lua_State}, idx::Cint)::Cvoid
end

function lua_setfield(L, idx, k)
    @ccall liblua.lua_setfield(L::Ptr{lua_State}, idx::Cint, k::Ptr{Cchar})::Cvoid
end

function lua_seti(L, idx, n)
    @ccall liblua.lua_seti(L::Ptr{lua_State}, idx::Cint, n::lua_Integer)::Cvoid
end

function lua_rawset(L, idx)
    @ccall liblua.lua_rawset(L::Ptr{lua_State}, idx::Cint)::Cvoid
end

function lua_rawseti(L, idx, n)
    @ccall liblua.lua_rawseti(L::Ptr{lua_State}, idx::Cint, n::lua_Integer)::Cvoid
end

function lua_rawsetp(L, idx, p)
    @ccall liblua.lua_rawsetp(L::Ptr{lua_State}, idx::Cint, p::Ptr{Cvoid})::Cvoid
end

function lua_setmetatable(L, objindex)
    @ccall liblua.lua_setmetatable(L::Ptr{lua_State}, objindex::Cint)::Cint
end

function lua_load(L, reader, dt, chunkname, mode)
    @ccall liblua.lua_load(L::Ptr{lua_State}, reader::lua_Reader, dt::Ptr{Cvoid}, chunkname::Ptr{Cchar}, mode::Ptr{Cchar})::Cint
end

function lua_dump(L, writer, data, strip)
    @ccall liblua.lua_dump(L::Ptr{lua_State}, writer::lua_Writer, data::Ptr{Cvoid}, strip::Cint)::Cint
end

function lua_resume(L, from, narg, nres)
    @ccall liblua.lua_resume(L::Ptr{lua_State}, from::Ptr{lua_State}, narg::Cint, nres::Ptr{Cint})::Cint
end

function lua_status(L)
    @ccall liblua.lua_status(L::Ptr{lua_State})::Cint
end

function lua_isyieldable(L)
    @ccall liblua.lua_isyieldable(L::Ptr{lua_State})::Cint
end

function lua_setwarnf(L, f, ud)
    @ccall liblua.lua_setwarnf(L::Ptr{lua_State}, f::lua_WarnFunction, ud::Ptr{Cvoid})::Cvoid
end

function lua_warning(L, msg, tocont)
    @ccall liblua.lua_warning(L::Ptr{lua_State}, msg::Ptr{Cchar}, tocont::Cint)::Cvoid
end

function lua_error(L)
    @ccall liblua.lua_error(L::Ptr{lua_State})::Cint
end

function lua_next(L, idx)
    @ccall liblua.lua_next(L::Ptr{lua_State}, idx::Cint)::Cint
end

function lua_concat(L, n)
    @ccall liblua.lua_concat(L::Ptr{lua_State}, n::Cint)::Cvoid
end

function lua_len(L, idx)
    @ccall liblua.lua_len(L::Ptr{lua_State}, idx::Cint)::Cvoid
end

function lua_stringtonumber(L, s)
    @ccall liblua.lua_stringtonumber(L::Ptr{lua_State}, s::Ptr{Cchar})::Csize_t
end

function lua_getallocf(L, ud)
    @ccall liblua.lua_getallocf(L::Ptr{lua_State}, ud::Ptr{Ptr{Cvoid}})::lua_Alloc
end

function lua_setallocf(L, f, ud)
    @ccall liblua.lua_setallocf(L::Ptr{lua_State}, f::lua_Alloc, ud::Ptr{Cvoid})::Cvoid
end

function lua_toclose(L, idx)
    @ccall liblua.lua_toclose(L::Ptr{lua_State}, idx::Cint)::Cvoid
end

function lua_closeslot(L, idx)
    @ccall liblua.lua_closeslot(L::Ptr{lua_State}, idx::Cint)::Cvoid
end

function lua_getstack(L, level, ar)
    @ccall liblua.lua_getstack(L::Ptr{lua_State}, level::Cint, ar::Ptr{lua_Debug})::Cint
end

function lua_getinfo(L, what, ar)
    @ccall liblua.lua_getinfo(L::Ptr{lua_State}, what::Ptr{Cchar}, ar::Ptr{lua_Debug})::Cint
end

function lua_getlocal(L, ar, n)
    @ccall liblua.lua_getlocal(L::Ptr{lua_State}, ar::Ptr{lua_Debug}, n::Cint)::Ptr{Cchar}
end

function lua_setlocal(L, ar, n)
    @ccall liblua.lua_setlocal(L::Ptr{lua_State}, ar::Ptr{lua_Debug}, n::Cint)::Ptr{Cchar}
end

function lua_getupvalue(L, funcindex, n)
    @ccall liblua.lua_getupvalue(L::Ptr{lua_State}, funcindex::Cint, n::Cint)::Ptr{Cchar}
end

function lua_setupvalue(L, funcindex, n)
    @ccall liblua.lua_setupvalue(L::Ptr{lua_State}, funcindex::Cint, n::Cint)::Ptr{Cchar}
end

function lua_upvalueid(L, fidx, n)
    @ccall liblua.lua_upvalueid(L::Ptr{lua_State}, fidx::Cint, n::Cint)::Ptr{Cvoid}
end

function lua_upvaluejoin(L, fidx1, n1, fidx2, n2)
    @ccall liblua.lua_upvaluejoin(L::Ptr{lua_State}, fidx1::Cint, n1::Cint, fidx2::Cint, n2::Cint)::Cvoid
end

function lua_sethook(L, func, mask, count)
    @ccall liblua.lua_sethook(L::Ptr{lua_State}, func::lua_Hook, mask::Cint, count::Cint)::Cvoid
end

function lua_gethook(L)
    @ccall liblua.lua_gethook(L::Ptr{lua_State})::lua_Hook
end

function lua_gethookmask(L)
    @ccall liblua.lua_gethookmask(L::Ptr{lua_State})::Cint
end

function lua_gethookcount(L)
    @ccall liblua.lua_gethookcount(L::Ptr{lua_State})::Cint
end

function lua_setcstacklimit(L, limit)
    @ccall liblua.lua_setcstacklimit(L::Ptr{lua_State}, limit::Cuint)::Cint
end

function luaopen_base(L)
    @ccall liblua.luaopen_base(L::Ptr{lua_State})::Cint
end

function luaopen_coroutine(L)
    @ccall liblua.luaopen_coroutine(L::Ptr{lua_State})::Cint
end

function luaopen_table(L)
    @ccall liblua.luaopen_table(L::Ptr{lua_State})::Cint
end

function luaopen_io(L)
    @ccall liblua.luaopen_io(L::Ptr{lua_State})::Cint
end

function luaopen_os(L)
    @ccall liblua.luaopen_os(L::Ptr{lua_State})::Cint
end

function luaopen_string(L)
    @ccall liblua.luaopen_string(L::Ptr{lua_State})::Cint
end

function luaopen_utf8(L)
    @ccall liblua.luaopen_utf8(L::Ptr{lua_State})::Cint
end

function luaopen_math(L)
    @ccall liblua.luaopen_math(L::Ptr{lua_State})::Cint
end

function luaopen_debug(L)
    @ccall liblua.luaopen_debug(L::Ptr{lua_State})::Cint
end

function luaopen_package(L)
    @ccall liblua.luaopen_package(L::Ptr{lua_State})::Cint
end

function luaL_openlibs(L)
    @ccall liblua.luaL_openlibs(L::Ptr{lua_State})::Cvoid
end

const LUA_GNAME = "_G"

const LUA_ERRERR = 5

const LUA_ERRFILE = LUA_ERRERR + 1

const LUA_LOADED_TABLE = "_LOADED"

const LUA_PRELOAD_TABLE = "_PRELOAD"

# Skipping MacroDefinition: LUAL_NUMSIZES ( sizeof ( lua_Integer ) * 16 + sizeof ( lua_Number ) )

const LUA_VERSION_NUM = 504

const LUA_NOREF = -2

const LUA_REFNIL = -1

const LUA_MULTRET = -1

const LUAI_MAXSTACK = 1000000

const LUA_REGISTRYINDEX = -LUAI_MAXSTACK - 1000

# Skipping MacroDefinition: LUAL_BUFFERSIZE ( ( int ) ( 16 * sizeof ( void * ) * sizeof ( lua_Number ) ) )

const LUA_FILEHANDLE = "FILE*"

const LUA_VERSION_MAJOR = "5"

const LUA_VERSION_MINOR = "4"

const LUA_VERSION_RELEASE = "7"

const LUA_VERSION_RELEASE_NUM = LUA_VERSION_NUM * 100 + 7

const LUA_AUTHORS = "R. Ierusalimschy, L. H. de Figueiredo, W. Celes"

const LUA_SIGNATURE = "\eLua"

const LUA_OK = 0

const LUA_YIELD = 1

const LUA_ERRRUN = 2

const LUA_ERRSYNTAX = 3

const LUA_ERRMEM = 4

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

const LUA_MINSTACK = 20

const LUA_RIDX_MAINTHREAD = 1

const LUA_RIDX_GLOBALS = 2

const LUA_RIDX_LAST = LUA_RIDX_GLOBALS

const LUA_OPADD = 0

const LUA_OPSUB = 1

const LUA_OPMUL = 2

const LUA_OPMOD = 3

const LUA_OPPOW = 4

const LUA_OPDIV = 5

const LUA_OPIDIV = 6

const LUA_OPBAND = 7

const LUA_OPBOR = 8

const LUA_OPBXOR = 9

const LUA_OPSHL = 10

const LUA_OPSHR = 11

const LUA_OPUNM = 12

const LUA_OPBNOT = 13

const LUA_OPEQ = 0

const LUA_OPLT = 1

const LUA_OPLE = 2

const LUA_GCSTOP = 0

const LUA_GCRESTART = 1

const LUA_GCCOLLECT = 2

const LUA_GCCOUNT = 3

const LUA_GCCOUNTB = 4

const LUA_GCSTEP = 5

const LUA_GCSETPAUSE = 6

const LUA_GCSETSTEPMUL = 7

const LUA_GCISRUNNING = 9

const LUA_GCGEN = 10

const LUA_GCINC = 11

# Skipping MacroDefinition: LUA_EXTRASPACE ( sizeof ( void * ) )

const LUA_NUMTAGS = LUA_NUMTYPES

const LUA_HOOKCALL = 0

const LUA_HOOKRET = 1

const LUA_HOOKLINE = 2

const LUA_HOOKCOUNT = 3

const LUA_HOOKTAILCALL = 4

const LUA_MASKCALL = 1 << LUA_HOOKCALL

const LUA_MASKRET = 1 << LUA_HOOKRET

const LUA_MASKLINE = 1 << LUA_HOOKLINE

const LUA_MASKCOUNT = 1 << LUA_HOOKCOUNT

const LUAI_IS32INT = UINT_MAX >> 30 >= 3

const LUA_INT_INT = 1

const LUA_INT_LONG = 2

const LUA_INT_LONGLONG = 3

const LUA_FLOAT_FLOAT = 1

const LUA_FLOAT_DOUBLE = 2

const LUA_FLOAT_LONGDOUBLE = 3

const LUA_INT_DEFAULT = LUA_INT_LONGLONG

const LUA_FLOAT_DEFAULT = LUA_FLOAT_DOUBLE

const LUA_32BITS = 0

const LUA_C89_NUMBERS = 0

const LUA_INT_TYPE = LUA_INT_DEFAULT

const LUA_FLOAT_TYPE = LUA_FLOAT_DEFAULT

const LUA_PATH_SEP = ";"

const LUA_PATH_MARK = "?"

const LUA_EXEC_DIR = "!"

const LUA_LDIR = "!\\lua\\"

const LUA_CDIR = "!\\"

# Skipping MacroDefinition: LUA_PATH_DEFAULT LUA_LDIR "?.lua;" LUA_LDIR "?\\init.lua;" LUA_CDIR "?.lua;" LUA_CDIR "?\\init.lua;" LUA_SHRDIR "?.lua;" LUA_SHRDIR "?\\init.lua;" ".\\?.lua;" ".\\?\\init.lua"

# Skipping MacroDefinition: LUA_CPATH_DEFAULT LUA_CDIR "?.dll;" LUA_CDIR "..\\lib\\lua\\" LUA_VDIR "\\?.dll;" LUA_CDIR "loadall.dll;" ".\\?.dll"

const LUA_DIRSEP = "\\"

const LUA_IGMARK = "-"

# Skipping MacroDefinition: LUAI_FUNC extern

const LUA_NUMBER_FMT = "%.14g"

const LUAI_UACNUMBER = Float64

const LUA_NUMBER = Float64

const LUA_INTEGER = Clonglong

const LUA_NUMBER_FRMLEN = ""

const LUA_INTEGER_FRMLEN = "ll"

const LUAI_UACINT = LUA_INTEGER

const LUA_UNSIGNED = unsigned(LUAI_UACINT)

const LUA_IDSIZE = 60

const LUA_COLIBNAME = "coroutine"

const LUA_TABLIBNAME = "table"

const LUA_IOLIBNAME = "io"

const LUA_OSLIBNAME = "os"

const LUA_STRLIBNAME = "string"

const LUA_UTF8LIBNAME = "utf8"

const LUA_MATHLIBNAME = "math"

const LUA_DBLIBNAME = "debug"

const LUA_LOADLIBNAME = "package"

#define lua_getextraspace(L)	((void *)((char *)(L) - LUA_EXTRASPACE))

lua_tonumber(L, i) = lua_tonumberx(L, (i), C_NULL)
#define lua_tointeger(L,i)	lua_tointegerx(L,(i),NULL)

lua_pop(L, n) = lua_settop(L, -(n)-1)

#define lua_newtable(L)		lua_createtable(L, 0, 0)

function lua_register(L, n, f)
    lua_pushcfunction(L, (f))
    lua_setglobal(L, (n))
    return nothing
end

lua_pushcfunction(L, f) = lua_pushcclosure(L, (f), 0)

#define lua_isfunction(L,n)	(lua_type(L, (n)) == LUA_TFUNCTION)
#define lua_istable(L,n)	(lua_type(L, (n)) == LUA_TTABLE)
#define lua_islightuserdata(L,n)	(lua_type(L, (n)) == LUA_TLIGHTUSERDATA)
#define lua_isnil(L,n)		(lua_type(L, (n)) == LUA_TNIL)
#define lua_isboolean(L,n)	(lua_type(L, (n)) == LUA_TBOOLEAN)
#define lua_isthread(L,n)	(lua_type(L, (n)) == LUA_TTHREAD)
#define lua_isnone(L,n)		(lua_type(L, (n)) == LUA_TNONE)
#define lua_isnoneornil(L, n)	(lua_type(L, (n)) <= 0)

#define lua_pushliteral(L, s)	lua_pushstring(L, "" s)

#define lua_pushglobaltable(L)  \
# ((void)lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS))

lua_tostring(L, i) = lua_tolstring(L, (i), C_NULL)

#define lua_insert(L,idx)	lua_rotate(L, (idx), 1)

function lua_remove(L, idx)
    lua_rotate(L, (idx), -1)
    lua_pop(L, 1)
    return nothing
end

#define lua_replace(L,idx)	(lua_copy(L, -1, (idx)), lua_pop(L, 1))

luaL_getmetatable(L, n) = lua_getfield(L, LUA_REGISTRYINDEX, (n))

end # module
