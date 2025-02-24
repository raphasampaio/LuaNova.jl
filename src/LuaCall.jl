module LuaCall

export from_lua, to_lua, @lua

include("capi.jl")
import .C

include("state.jl")

macro lua(fndef)
    # Ensure the macro is applied to a function definition.
    if fndef.head != :function
        error("@lua macro must be applied to a function definition")
    end

    # Extract the function name.
    local fn_name_sym = if isa(fndef.args[1], Symbol)
        fndef.args[1]
    elseif isa(fndef.args[1], Expr) && fndef.args[1].head == :call
        fndef.args[1].args[1]
    else
        error("@lua: invalid function signature")
    end

    # Create a name for the Lua callback wrapper.
    local wrapper_name = Symbol(string(fn_name_sym) * "_lua")

    # Build an expression for the wrapper definition.
    local wrapper_expr = quote
        function $(QuoteNode(wrapper_name))(L::Ptr{Cvoid})::Cint
            local args = LuaCall.from_lua(L)
            local result = $(esc(fn_name_sym))(args...)
            return LuaCall.to_lua(L, result)
        end
    end

    return quote
        # Define the original function normally.
        $(esc(fndef))
        # At runtime, inject the Lua callback wrapper into Main.
        Core.eval(Main, $(QuoteNode(wrapper_expr)))
    end
end




end
