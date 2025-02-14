function test_aqua()
    @testset "Ambiguities" begin
        Aqua.test_ambiguities(LuaCall, recursive = false)
    end
    Aqua.test_all(LuaCall, ambiguities = false)

    return nothing
end
