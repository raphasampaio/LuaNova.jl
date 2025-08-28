module TestTables

using LuaNova
using Test

@testset "Tables" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    LuaNova.new_table(L)
    LuaNova.push_to_lua!(L, "key")
    LuaNova.push_to_lua!(L, 42)
    LuaNova.set_table(L, -3)

    LuaNova.push_to_lua!(L, "key")
    LuaNova.get_table(L, -2)
    result = LuaNova.to_number(L, -1)
    @test result == 42

    LuaNova.close(L)

    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    LuaNova.safe_script(L, "t = {\"a\", \"b\", \"c\"};")
    
    LuaNova.get_global(L, "t")
    @test LuaNova.is_table(L, -1)
    
    LuaNova.push_to_lua!(L, 1)
    LuaNova.get_table(L, -2)
    result1 = LuaNova.to_string(L, -1)
    @test result1 == "a"
    LuaNova.lua_pop!(L, 1)
    
    LuaNova.push_to_lua!(L, 2)
    LuaNova.get_table(L, -2)
    result2 = LuaNova.to_string(L, -1)
    @test result2 == "b"
    LuaNova.lua_pop!(L, 1)
    
    LuaNova.push_to_lua!(L, 3)
    LuaNova.get_table(L, -2)
    result3 = LuaNova.to_string(L, -1)
    @test result3 == "c"
    LuaNova.lua_pop!(L, 1)
    
    table_length = LuaNova.raw_len(L, -1)
    @test table_length == 3
    
    LuaNova.lua_pop!(L, 1)

    LuaNova.close(L)    

    return nothing
end

end
