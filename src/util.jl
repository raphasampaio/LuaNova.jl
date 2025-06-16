to_cstring(s::AbstractString) = Base.unsafe_convert(Ptr{Cchar}, pointer(s))
