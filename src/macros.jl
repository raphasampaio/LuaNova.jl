function push_lua_value(L::Ptr{Cvoid}, value)
    if value isa Number
        C.lua_pushnumber(L, value)
    elseif value isa String
        C.lua_pushstring(L, value)
    elseif value isa Ptr
        C.lua_pushlightuserdata(L, value)
    else
        error("Unsupported value type")
    end
end

function pop_lua_value(L::Ptr{Cvoid}, index::Integer)
    C.luaL_checktype(L, index, Lua.TANY)
    t = C.lua_type(L, index)

    if t == Lua.LUA_TNUMBER
        return C.lua_tonumber(L, index)
    elseif t == Lua.LUA_TSTRING
        return C.lua_tostring(L, index)
    elseif t == Lua.LUA_TLIGHTUSERDATA
        return C.lua_touserdata(L, index)
    else
        error("Unsupported Lua value type")
    end
end

macro define_lua_function(function_name)
    return esc(quote
        function $function_name(L::Ptr{Cvoid})::Cint
            args = LuaNova.from_lua(L)
            result = $function_name(args...)
            return LuaNova.to_lua(L, result)
        end
    end)
end

macro push_lua_function(L, lua_function, julia_function)
    return esc(quote
        f = @cfunction($julia_function, Cint, (Ptr{Cvoid},))
        LuaNova.C.lua_pushcfunction($L, f)
        LuaNova.C.lua_setglobal($L, $lua_function)
    end)
end

macro define_lua_struct(struct_name)
    struct_string = string(struct_name)

    return esc(quote
        function $struct_name(L::Ptr{LuaNova.C.lua_State})::Cint
            args = LuaNova.from_lua(L)
            object = $struct_name(args...)

            userdata = LuaNova.C.lua_newuserdatauv(L, Csize_t(0), 0)
            LuaNova.REGISTRY[Ptr{Cvoid}(userdata)] = Ref(object)
            LuaNova.C.luaL_setmetatable(L, to_cstring($struct_string))

            return 1
        end
    end)
end

macro printfields(T)
    T_ty = if T isa Symbol
        getfield(__module__, T)
    elseif T isa Expr
        eval(__module__, T)
    else
        error("@printfields: expected a type name or expression, got $T")
    end

    names = fieldnames(T_ty)      # tuple of Symbols
    types = fieldtypes(T_ty)      # tuple of Types

    stmts = Expr[]
    for (n, t) in zip(names, types)
        # string(n) → "a", QuoteNode(t) → literal type
        push!(stmts, :(
            println($(QuoteNode(string(n))), " :: ", $(QuoteNode(t)))
        ))
    end

    return Expr(:block, stmts...)
end

# macro make_index(T)
#      # resolve type and its fields in caller’s module
#     mod = __module__
#     T_ty = T isa Symbol ? getfield(mod, T) : eval(mod, T)
#      fields   = fieldnames(T_ty)
#      T_str    = string(T)
#      idx_fn   = Symbol(string(T)*"_index")
#      new_fn   = Symbol(string(T)*"_newindex")

#     # build __index chain
#     cond    = :(key == $(string(fields[1])))
#     body    = :(LuaNova.push(L, getfield(obj, $(QuoteNode(fields[1])))))
#     current = Expr(:if, cond, body, nothing)
#     tail    = current
#     for f in fields[2:end]
#         cond = :(key == $(string(f)))
#         body = :(LuaNova.push(L, getfield(obj, $(QuoteNode(f)))))
#         next = Expr(:if, cond, body, nothing)
#         tail.args[3] = next
#         tail = next
#     end
#     tail.args[3] = quote
#         LuaNova.C.luaL_getmetatable(L, to_cstring($T_str))
#         LuaNova.C.lua_pushvalue(L, 2)
#         LuaNova.C.lua_gettable(L, -2)
#     end

#     # build __newindex chain
#     cond2   = :(key == $(string(fields[1])))
#     body2   = :(obj.$(fields[1]) = val)
#     curr2   = Expr(:if, cond2, body2, nothing)
#     tail2   = curr2
#     for f in fields[2:end]
#         cond2 = :(key == $(string(f)))
#         body2 = :(obj.$(f) = val)
#         next2 = Expr(:if, cond2, body2, nothing)
#         tail2.args[3] = next2
#         tail2 = next2
#     end
#     tail2.args[3] = :(LuaNova.C.luaL_argerror(L, 2, to_cstring("invalid field")))

#     return esc(quote
#         function $(idx_fn)(L::Ptr{LuaNova.C.lua_State})::Cint
#             obj = LuaNova.get_reference(L, Int32(1), $T_str)
#             key = unsafe_string(LuaNova.C.luaL_checklstring(L, 2, C_NULL))
#             $current
#             return 1
#         end

#         function $(new_fn)(L::Ptr{LuaNova.C.lua_State})::Cint
#             obj = LuaNova.get_reference(L, Int32(1), $T_str)
#             key = unsafe_string(LuaNova.C.luaL_checklstring(L, 2, C_NULL))
#             val = (LuaNova.from_lua(L))[2]
#             $curr2
#             return 0
#         end
#     end)
# end

macro push_lua_struct(L, struct_name, args...)
    n = length(args)
    isodd(n) && error("@push_lua_struct needs key fn pairs (got $n args)")

    struct_string = string(struct_name)
    gc_fn    = Symbol(string(struct_name)*"_gc")
    idx_fn   = Symbol(string(struct_name)*"_index")
    new_fn   = Symbol(string(struct_name)*"_newindex")

    method_entries = Expr[]
    push!(method_entries,
        :(LuaNova.C.luaL_Reg(to_cstring("__gc"),      @cfunction($(gc_fn),  Cint, (Ptr{LuaNova.C.lua_State},)))))
    push!(method_entries,
        :(LuaNova.C.luaL_Reg(to_cstring("__index"),   @cfunction($(idx_fn), Cint, (Ptr{LuaNova.C.lua_State},)))))
    push!(method_entries,
        :(LuaNova.C.luaL_Reg(to_cstring("__newindex"),@cfunction($(new_fn), Cint, (Ptr{LuaNova.C.lua_State},)))))

    for i in 1:2:n
        key = args[i]; fn = args[i+1]
        push!(method_entries,
            :(LuaNova.C.luaL_Reg(to_cstring($key), @cfunction($fn, Cint, (Ptr{Cvoid},)))))
    end
    push!(method_entries, :(LuaNova.C.luaL_Reg(C_NULL, C_NULL)))
    methods_vect = Expr(:vect, method_entries...)

    return esc(quote
        LuaNova.C.luaL_newmetatable($L, to_cstring($(struct_string)))
        local methods = $methods_vect
        LuaNova.C.luaL_setfuncs($L, pointer(methods), 0)
        LuaNova.C.lua_pop($L, 1)

        # constructor
        LuaNova.C.lua_pushcclosure($L,
            @cfunction($struct_name, Cint, (Ptr{LuaNova.C.lua_State},)), 0)
        LuaNova.C.lua_setglobal($L, to_cstring($struct_string))
    end)
end