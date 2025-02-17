module LuaCall

using FunctionWrappers
import FunctionWrappers: FunctionWrapper

export safe_script, lua_register, finalize_lua_registration

include("capi.jl")
import .C

include("state.jl")

const CACHE = Dict{Symbol, Dict{DataType, FunctionWrapper}}()

function lua_register(function_name::Symbol, return_type::DataType, arg_types::Vector{DataType}, definition::Function)
    if !haskey(CACHE, function_name)
        CACHE[function_name] = Dict{DataType, FunctionWrapper}()
    end

    signature_type = Tuple{arg_types...}
    
    CACHE[function_name][signature_type] = FunctionWrapper{return_type, signature_type}(definition)

    return nothing
end

# ---------------------------------------------------------
# 2) A struct to hold the function & signature
#    We'll make this struct callable, so that
#    cb(L) does all the argument parsing + calling.
# ---------------------------------------------------------
struct LuaCallback
    signature_type::DataType
    return_type::DataType
    julia_func::Function
end

# The "call" method for LuaCallback:
# This is what actually gets invoked from Lua -> Julia.
function (cb::LuaCallback)(L::Ptr{Cvoid})::Cint
    # 1) Read the number of arguments from Lua
    nargs = C.lua_gettop(L)

    # 2) For demonstration, parse them as Float64
    #    In real usage, you'd parse them according to `cb.signature_type`.
    args = Float64[]
    for i in 1:nargs
        if C.lua_isnumber(L, i) != 0
            push!(args, C.lua_tonumber(L, i))
        else
            error("Argument $i is not a number in Lua call")
        end
    end

    # 3) Call the stored Julia function
    result = cb.julia_func(args...)

    # 4) Push the result (assuming Float64 for example)
    C.lua_pushnumber(L, result)

    # 5) Return how many results we pushed
    return 1
end

# ---------------------------------------------------------
# 3) A factory that returns a `Ptr{Cvoid}` function
#    that Lua can call.  It does this by:
#       - Building a LuaCallback struct
#       - Creating an *anonymous* function that calls cb
#       - Using @cfunction to turn that into a pointer
# ---------------------------------------------------------
function lua_cfunction_factory(signature_type::DataType, return_type::DataType, julia_func::Function)::Ptr{Cvoid}
    # Create the callback object
    cb = LuaCallback(signature_type, return_type, julia_func)

    # Wrap cb(...) in an anonymous function
    # that matches the cfunction signature: Cint(Ptr{Cvoid}).
    return @cfunction((L::Ptr{Cvoid}) -> cb(L), Cint, (Ptr{Cvoid},))
end

# ---------------------------------------------------------
# 4) The finalize function that registers in Lua
# ---------------------------------------------------------
function finalize_lua_registration(L, func_name::Symbol)
    if !haskey(CACHE, func_name)
        return
    end

    for (signature_type, fw) in CACHE[func_name]
        @show fw
        # `fw` is a FunctionWrapper{R, A}
        R, A = typeof(fw).parameters  # R is the return type, A is the arg-types tuple

        # For example, we might build a Lua-friendly name:
        @show lua_name = string(
            func_name, "_",
            join([string(t) for t in A.parameters], "_")
        )

        let function_wrapper = fw

        # Now, to *call* the function, use `fw(...)` directly:
        #   result = fw(x, y, ...)
        #
        # For registering with Lua, you can still do an @cfunction of an anonymous closure:
        ptr = @cfunction(
            (L::Ptr{Cvoid}) -> begin
                nargs = C.lua_gettop(L)
                args = Float64[]  # example
                for i in 1:nargs
                    if C.lua_isnumber(L, i) != 0
                        push!(args, C.lua_tonumber(L, i))
                    else
                        error("Argument $i is not a number in Lua call")
                    end
                end
                # Call the FunctionWrapper itself
                result = function_wrapper(args...)

                # push the result
                C.lua_pushnumber(L, result)
                return 1
            end,
            Cint, (Ptr{Cvoid},)
        )

        # Finish registration
        C.lua_pushcfunction(L, ptr)
        C.lua_setglobal(L, lua_name)
        end
    end
end


end
