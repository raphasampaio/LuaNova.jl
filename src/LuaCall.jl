module LuaCall

export @lua

include("capi.jl")
import .C

# A reference to an opened Lua state. You could also make this a parameter, etc.
# For demo purposes, we create it here.
const L = C.luaL_newstate()
C.luaL_openlibs(L)  # open standard libraries

# Global dictionary: function name => vector of (signature, function) pairs
const OVERLOADS = Dict{Symbol, Vector{Tuple{Vector{DataType},Function}}}()

###############################################################################
# 1) A single dispatcher function used by all overloaded calls
###############################################################################
function _lua_dispatcher(L::Ptr{Cvoid})::Cint
    # We stored the function's name in a Lua upvalue if we want (1 upvalue).
    # Alternatively, for demonstration, let's assume we
    # can get it from the Lua "registry index" or store in a global. For brevity:
    # We'll use lua_upvalueindex(1) to retrieve the function name (string).
    fnname = unsafe_string(C.lua_tostring(L, C.lua_upvalueindex(1)))

    # Retrieve the overloads from the global dictionary
    symbolname = Symbol(fnname)
    overloadlist = get(OVERLOADS, symbolname, nothing)
    if overloadlist === nothing
        # No function by that name is known
        C.lua_pushstring(L, "No registered LuaOverloads for function: $fnname")
        C.lua_error(L)
        return 0  # unreachable
    end

    # Count arguments on the Lua stack
    nargs = C.lua_gettop(L)

    # Attempt to match each stored overload
    for (sigtypes, juliafn) in overloadlist
        # If the argument counts differ, skip
        if length(sigtypes) != nargs
            continue
        end

        # Attempt to convert each Lua argument to the corresponding Julia type
        converted_args = Vector{Any}(undef, nargs)
        failed = false
        for i in 1:nargs
            desired_t = sigtypes[i]
            # Very simple demonstration dispatch:
            if desired_t === Float64
                if C.lua_isnumber(L, i) == 1
                    converted_args[i] = C.lua_tonumber(L, i)
                else
                    failed = true
                    break
                end
            elseif desired_t === String
                if C.lua_isstring(L, i) == 1
                    converted_args[i] = unsafe_string(C.lua_tostring(L, i))
                else
                    failed = true
                    break
                end
            else
                # For demonstration, we only handle Float64 or String.
                # Real code would handle more or raise error.
                failed = true
                break
            end
        end

        # If we didn't fail, we have a match, so call the Julia function
        if !failed
            retval = juliafn(converted_args...) 
            # Push return value(s) onto the stack
            # We'll assume a single Int return for demonstration
            C.lua_pushinteger(L, retval)
            return 1  # number of return values
        end
    end

    # If no overload matched, raise Lua error
    C.lua_pushstring(L, "No overload matched for function: $fnname")
    C.lua_error(L)
    return 0  # unreachable
end

###############################################################################
# 2) A helper to register a global function in Lua
###############################################################################
function _register_lua_function(name::Symbol)
    # We push the function name as a closed-over upvalue
    # then push the `_lua_dispatcher` as a cfunction.
    # So the final callable has 1 upvalue (the function name).
    fnname_str = string(name)

    # Push the function name (as upvalue #1)
    C.lua_pushstring(L, fnname_str)

    # Create a cfunction pointer to _lua_dispatcher
    dispatcher_ptr = @cfunction(_lua_dispatcher, Cint, (Ptr{Cvoid},))
    # Push that cfunction as a closure with 1 upvalue on the stack
    C.lua_pushcclosure(L, dispatcher_ptr, 1)

    # Now set it as a global in Lua
    C.lua_setglobal(L, fnname_str)
end

###############################################################################
# 3) The macro that intercepts a `function foo(...) ... end` definition
###############################################################################
# macro lua(ex)
#     # We expect something like: @lua function foo(...) ... end
#     # so ex should be an Expr(:function, ..., ...) at top level
#     if !(ex isa Expr && ex.head == :function)
#         error("@lua must wrap a 'function' definition.")
#     end

#     # ex.args is typically [signature, body_expr]
#     fn_expr = ex.args[1]  # could be a Symbol or an Expr(:call, ...)
#     fun_body = ex.args[2]

#     # Extract the function name and argument expressions
#     fn_name_sym = nothing
#     arg_exprs   = nothing

#     if fn_expr isa Symbol
#         # e.g. function foo(...) end
#         fn_name_sym = fn_expr
#         # The argument list is in fun_body.args[1]
#         arg_exprs = fun_body.args[1]
#     elseif fn_expr isa Expr && fn_expr.head == :call
#         # e.g. function foo(x::Float64, y::String)
#         # Then fn_expr.args[1] is the function name (:foo),
#         # and fn_expr.args[2:end] are the arguments (x::Float64, y::String).
#         fn_name_sym = fn_expr.args[1]
#         # Construct a fake "tuple" expression out of fn_expr.args[2:end],
#         # so it's consistent with typical function body parsing
#         arg_exprs = Expr(:tuple, fn_expr.args[2:end]...)
#     else
#         error("Unsupported function definition form: $fn_expr")
#     end

#     # Check that we got a Symbol
#     if !(fn_name_sym isa Symbol)
#         error("Function name must be a symbol, got $fn_name_sym")
#     end

#     # Now parse the typed arguments from arg_exprs
#     # arg_exprs is something like Expr(:tuple, :(x::Float64), :(y::String)) if typed
#     # or Expr(:tuple, :x, :y) if untyped, etc.
#     sig_types = Vector{DataType}()
#     arg_syms  = Vector{Symbol}()
#     for a in arg_exprs.args
#         if a isa Symbol
#             # untyped argument
#             push!(sig_types, Any)
#             push!(arg_syms, a)
#         elseif a isa Expr && a.head == :(::)
#             # typed argument, e.g. x::Float64
#             push!(arg_syms, a.args[1])
#             t_sym = a.args[2]
#             push!(sig_types, eval(t_sym))  # naive approach
#         else
#             error("Unsupported argument format in $a")
#         end
#     end

#     # Now we have: 
#     #  - fn_name_sym as the function name (Symbol)
#     #  - sig_types as a vector of DataTypes
#     #  - The rest of ex is the function's body.

#     # We want to splice back in a normal function definition of the simpler form:
#     #    function fn_name_sym(...args typed or untyped...)
#     #        (original body)
#     #    end

#     # We also do whatever registration or Overloads logic is needed. 
#     # This is just a schematic example for the fix:

#     quote
#         # (1) Define the function as normal
#         $(esc(ex))  # This expands to: function foo(x::Float64, ...) ... end

#         # (2) Possibly do some further logic:
#         #     e.g. store signature in a global dictionary, register with Lua, etc.
#         println("Successfully defined @lua function $(string($fn_name_sym)) with signature $(sig_types).")

#         # Return the name or the function object
#         # Up to you how you want the macro to behave
#         nothing
#     end
# end

# macro lua(ex)
#     # We expect something like:
#     #   @lua function foo(x::Float64)
#     #       println(x)
#     #       return 0
#     #   end
#     #
#     # The expression's structure should be: 
#     #   :(function foo(args...) body... end)
#     if !(ex isa Expr && ex.head == :function)
#         error("@lua must wrap a 'function' definition.")
#     end

#     # Extract the function name
#     fn_name_expr = ex.args[1]
#     # fn_name_expr is usually a symbol for simple definitions: :foo
#     # or it can be an expression for fun like getindex(...). We assume simple symbol.
#     fn_name_sym = fn_name_expr isa Symbol ? fn_name_expr : 
#         error("Function name must be a simple symbol, got $fn_name_expr")

#     # Extract the argument list & body
#     # ex.args[2] is the function body expression
#     # We can parse the signature from the function's arguments:
#     # ex.args[1] is the signature expression. Let's look at details:
#     # For something like (x::Float64, y::String) => 
#     # an Expr(:tuple, :x::Float64, :y::String)
#     fun_body = ex.args[2]

#     # We'll gather the declared argument types in a vector
#     # We have to parse each argument expression, which might be e.g. :(x::Float64)
#     # or just :x if there's no type.
#     arg_exprs = fun_body.args[1]  # the list of argument expressions
#     sig_types = Vector{DataType}()
#     arg_syms  = Vector{Symbol}()
#     for arg in arg_exprs.args
#         if isa(arg, Symbol)
#             # no type annotation
#             push!(sig_types, Any)
#             push!(arg_syms, arg)
#         elseif isa(arg, Expr) && arg.head == :(::) # typed argument, e.g. :(x::Float64)
#             # the form is Expr(:colon, Symbol("x"), Symbol("Float64")) or so
#             # e.g. arg.args = [ :x, :Float64 ] 
#             push!(arg_syms, arg.args[1])
#             t_sym = arg.args[2]
#             # Evaluate that symbol in Main to get a type for demonstration
#             # (in real code you'd want a safer approach).
#             push!(sig_types, eval(t_sym))
#         else
#             error("Unsupported argument format in $arg")
#         end
#     end

#     # Overwrite ex so that we define a normal Julia function but the macro can also
#     # capture its method. We'll store the *original* function body so we can compile it.

#     # We want to generate code that:
#     # 1) Defines the function normally in Julia
#     # 2) Appends (sig_types, the function) to OVERLOADS[fn_name_sym]
#     # 3) Calls _register_lua_function(fn_name_sym)

#     quote
#         # 1) Define the function
#         $(esc(ex))

#         # 2) Grab the newly defined method object as a Function
#         #    We can just refer to the symbol name: `foo`
#         the_function = getfield(Main, $(QuoteNode(fn_name_sym)))

#         # 3) Append to the overloads table
#         if !haskey($OVERLOADS, $(QuoteNode(fn_name_sym)))
#             $OVERLOADS[$(QuoteNode(fn_name_sym))] = Vector{Tuple{Vector{DataType},Function}}()
#         end
#         push!($OVERLOADS[$(QuoteNode(fn_name_sym))], (Vector{DataType}($(sig_types...)), the_function))

#         # 4) Register (or re-register) this name with Lua
#         #    This ensures the global name in Lua sees the dispatcher.
#         _register_lua_function($(QuoteNode(fn_name_sym)))

#         # return the function itself
#         the_function
#     end
# end

macro lua(ex)
    # We expect: @lua function foo(...) ... end
    # ex should be something like: Expr(:function, signature, body)
    if !(ex isa Expr && ex.head == :function)
        error("@lua must wrap a 'function' definition.")
    end

    fn_expr = ex.args[1]  # could be Symbol(:foo) or Expr(:call, :foo, arg1, ...)
    fun_body = ex.args[2]

    # We'll parse out the function name symbol and a "tuple" of argument exprs.
    fn_name_sym = nothing
    arg_tuple_expr = nothing

    if fn_expr isa Symbol
        # e.g. function foo(...)
        fn_name_sym = fn_expr
        # The argument list is in fun_body.args[1]
        arg_tuple_expr = fun_body.args[1]
    elseif fn_expr isa Expr && fn_expr.head == :call
        # e.g. function foo(x::Float64)
        # then fn_expr.args[1] is :foo
        # and fn_expr.args[2:end] are the argument expressions
        fn_name_sym = fn_expr.args[1]
        arg_tuple_expr = Expr(:tuple, fn_expr.args[2:end]...)
    else
        error("Unsupported function definition form: $fn_expr")
    end

    if !(fn_name_sym isa Symbol)
        error("Function name must be a symbol, got $fn_name_sym")
    end

    # Extract typed arguments from arg_tuple_expr.
    # We'll build a Vector{DataType} named `sig_types`.
    sig_types = Vector{DataType}()
    for a in arg_tuple_expr.args
        if a isa Symbol
            # untyped argument => default to Any
            push!(sig_types, Any)
        elseif a isa Expr && a.head == :(::)
            # typed argument, e.g. x::Float64
            t_sym = a.args[2]
            push!(sig_types, eval(t_sym))  # naive approach
        else
            error("Unsupported argument format in $a")
        end
    end

    quote
        # 1) Define the user’s function in the caller's module scope
        $(esc(ex))

        # 2) Retrieve the newly defined function by name from the caller’s module
        the_function = getfield(@__MODULE__, $(QuoteNode(fn_name_sym)))

        # 3) Store the new overload (signature + function) in OVERLOADS
        if !haskey($OVERLOADS, $(QuoteNode(fn_name_sym)))
            $OVERLOADS[$(QuoteNode(fn_name_sym))] = Vector{Tuple{Vector{DataType}, Function}}()
        end

        # <-- The critical fix: just store `sig_types` directly, no extra constructor. -->
        push!($OVERLOADS[$(QuoteNode(fn_name_sym))], (sig_types, the_function))

        # 4) Register (or re-register) the dispatcher in Lua under this name
        _register_lua_function($(QuoteNode(fn_name_sym)))

        # Return the function object
        the_function
    end
end


end
