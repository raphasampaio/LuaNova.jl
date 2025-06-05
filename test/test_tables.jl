module TestTables

using LuaNova
using Test

@testset "Tables" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    LuaNova.new_table(L)
    LuaNova.push_string(L, "key")
    LuaNova.push_number(L, 42)
    LuaNova.set_table(L, -3)

    LuaNova.push_string(L, "key")
    LuaNova.get_table(L, -2)
    result = LuaNova.to_number(L, -1)
    @test result == 42

    LuaNova.close(L)

    return nothing
end

end