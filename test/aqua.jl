function test_aqua()
    @testset "Ambiguities" begin
        Aqua.test_ambiguities(LuaNova, recursive = false)
    end
    Aqua.test_all(LuaNova, ambiguities = false)

    return nothing
end
