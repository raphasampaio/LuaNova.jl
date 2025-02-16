# """
# Finalize the Lua registration for `func_name`.

# This creates a single C bridging function that (1) inspects how many
# arguments are passed in from Lua, (2) tries to classify each argument
# as either Int or Float64, (3) matches the signature against 
# `registered_methods[func_name]`, and (4) calls the correct Julia
# method. The single bridging function is stored under the global 
# Lua name `string(func_name)`.

# If there's no match, we raise an error in Lua.
# """
# function finalize_lua_registration(func_name::Symbol)
#     methods_for_name = get(registered_methods, func_name, nothing)
#     if methods_for_name === nothing || isempty(methods_for_name)
#         error("No methods registered for function $func_name")
#     end

#     # We define a single Julia function that does the "runtime dispatch".
#     # We'll name it, e.g., `bridge_<func_name>`.
#     dispfun_name = Symbol("bridge_", func_name)
    
#     dispfun_code = quote
#         function $(dispfun_name)(L::Ptr{Nothing})::Cint
#             # Number of arguments from Lua
#             nargs = ccall((:lua_gettop, $liblua), Cint, (Ptr{Nothing},), L)
            
#             # Extract them all as float if possible, 
#             # then decide if we can convert to Int or keep as Float64.
#             # (In real usage, you might want more nuanced logic: strings, etc.)
#             values = Vector{Any}(undef, nargs)
#             for i in 1:nargs
#                 # We'll read each as a double:
#                 v_f64 = ccall((:luaL_checknumber, $liblua), Cdouble,
#                               (Ptr{Nothing}, Cint), L, i)
                
#                 # Also check if the same integer is representable 
#                 # by reading via luaL_optinteger or by checking fractional part:
#                 # (Here we do a naive check: if floor == v_f64, call it an Int)
#                 v_int = Int64(round(v_f64))  # careful w/ range
#                 if abs(v_f64 - v_int) < 1e-14
#                     values[i] = v_int
#                 else
#                     values[i] = v_f64
#                 end
#             end
            
#             # Attempt to match `values` against each known signature
#             # in `registered_methods[func_name]`.
#             # For each known method, we check same length and type match:
#             for (sig, f) in $methods_for_name
#                 if length(sig) == nargs
#                     # check each argument:
#                     local can_call = true
#                     for j in 1:nargs
#                         Tj = sig[j]
#                         aj = values[j]
#                         if !(aj isa Tj)
#                             can_call = false
#                             break
#                         end
#                     end
#                     if can_call
#                         # We found a matching method. Call it:
#                         local result = f(values...)
#                         # push it to Lua as a number (assuming it’s Float64):
#                         ccall((:lua_pushnumber, $liblua), Cvoid, 
#                               (Ptr{Nothing}, Cdouble), L, result)
#                         return 1
#                     end
#                 end
#             end
            
#             # If no match was found:
#             ccall((:luaL_error, $liblua), Cint, 
#                   (Ptr{Nothing}, Cstring),
#                   L, "No matching method for function $(string(func_name)) with these argument types.")
#             return 0  # unreachable if luaL_error actually throws
#         end
#     end
    
#     # Evaluate that bridging function in this module:
#     @eval $dispfun_code
    
#     # Now turn that bridging function into a C‐function pointer:
#     dispfun_ptr_name = Symbol(dispfun_name, "_ptr")
#     @eval begin
#         const $dispfun_ptr_name = @cfunction($dispfun_name, Cint, (Ptr{Nothing},))
#     end
    
#     # Finally, push it into Lua under the global name `string(func_name)`.
#     lua_name = string(func_name)
#     ccall((:lua_pushcclosure, liblua), Cvoid,
#           (Ptr{Nothing}, Ptr{Nothing}, Cint),
#           global_L, getfield(@__MODULE__, dispfun_ptr_name), 0)
#     ccall((:lua_setglobal, liblua), Cvoid,
#           (Ptr{Nothing}, Cstring),
#           global_L, lua_name)
    
#     return nothing
# end
