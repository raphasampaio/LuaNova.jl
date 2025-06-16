function to_cstring(s::AbstractString) 
    return Base.unsafe_convert(Ptr{Cchar}, pointer(s))
end

function to_string(T::Type)
    return string(nameof(T))
end
