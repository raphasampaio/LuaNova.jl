function test_aqua()
    @testset "Ambiguities" begin
        Aqua.test_ambiguities(Lua, recursive = false)
    end
    Aqua.test_all(Lua, ambiguities = false)

    return nothing
end
