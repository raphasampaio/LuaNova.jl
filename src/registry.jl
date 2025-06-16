# Registry to hold the references so they are not gc’d
const REGISTRY = IdDict{Ptr{Cvoid}, Ref}()

function get_reference(L::LuaState, idx::Integer, name::String)
    userdata = lua_check_userdata(L, idx, name)
    pointer = Ptr{Cvoid}(userdata)
    return REGISTRY[pointer][]
end
