module TestAqua

using Aqua
using LuaNova
using Test

@testset "Aqua" begin
    Aqua.test_ambiguities(LuaNova, recursive = false)
    Aqua.test_all(LuaNova, ambiguities = false)
    return nothing
end

end