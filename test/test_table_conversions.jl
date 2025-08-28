module TestTableConversions

using LuaNova
using Test

@testset "Table Conversions" begin
    @testset "lua_table_to_vector" begin
        L = LuaNova.new_state()
        LuaNova.open_libs(L)

        # Test simple array with numbers
        LuaNova.safe_script(L, "arr1 = {1, 2, 3, 4, 5}")
        LuaNova.get_global(L, "arr1")
        result1 = LuaNova.lua_table_to_vector(L, -1)
        @test result1 == [1.0, 2.0, 3.0, 4.0, 5.0]
        LuaNova.lua_pop!(L, 1)

        # Test array with mixed types
        LuaNova.safe_script(L, "arr2 = {42, \"hello\", true, false}")
        LuaNova.get_global(L, "arr2")
        result2 = LuaNova.lua_table_to_vector(L, -1)
        @test result2[1] == 42.0
        @test result2[2] == "hello"
        @test result2[3] == true
        @test result2[4] == false
        LuaNova.lua_pop!(L, 1)

        # Test array with nil values
        LuaNova.safe_script(L, "arr3 = {1, nil, 3}")
        LuaNova.get_global(L, "arr3")
        result3 = LuaNova.lua_table_to_vector(L, -1)
        @test length(result3) == 3  # raw_len returns 3 even with nil in the middle
        @test result3[1] == 1.0
        @test result3[2] === nothing
        @test result3[3] == 3.0
        LuaNova.lua_pop!(L, 1)

        # Test empty array
        LuaNova.safe_script(L, "arr4 = {}")
        LuaNova.get_global(L, "arr4")
        result4 = LuaNova.lua_table_to_vector(L, -1)
        @test length(result4) == 0
        LuaNova.lua_pop!(L, 1)

        # Test nested tables (should convert inner tables to dicts)
        LuaNova.safe_script(L, "arr5 = {1, {a = 2, b = 3}, 4}")
        LuaNova.get_global(L, "arr5")
        result5 = LuaNova.lua_table_to_vector(L, -1)
        @test result5[1] == 1.0
        @test isa(result5[2], Dict)
        @test result5[2]["a"] == 2.0
        @test result5[2]["b"] == 3.0
        @test result5[3] == 4.0
        LuaNova.lua_pop!(L, 1)

        LuaNova.close(L)
    end

    @testset "lua_table_to_dict" begin
        L = LuaNova.new_state()
        LuaNova.open_libs(L)

        # Test simple hash table with string keys
        LuaNova.safe_script(L, "dict1 = {name = \"John\", age = 30, active = true}")
        LuaNova.get_global(L, "dict1")
        result1 = LuaNova.lua_table_to_dict(L, -1)
        @test result1["name"] == "John"
        @test result1["age"] == 30.0
        @test result1["active"] == true
        LuaNova.lua_pop!(L, 1)

        # Test hash table with numeric keys
        LuaNova.safe_script(L, "dict2 = {[1] = \"first\", [10] = \"tenth\", [5] = \"fifth\"}")
        LuaNova.get_global(L, "dict2")
        result2 = LuaNova.lua_table_to_dict(L, -1)
        @test result2[1.0] == "first"
        @test result2[10.0] == "tenth"
        @test result2[5.0] == "fifth"
        LuaNova.lua_pop!(L, 1)

        # Test hash table with mixed key types
        LuaNova.safe_script(L, "dict3 = {name = \"value\", [42] = \"number\", [true] = \"boolean\"}")
        LuaNova.get_global(L, "dict3")
        result3 = LuaNova.lua_table_to_dict(L, -1)
        @test result3["name"] == "value"
        @test result3[42.0] == "number"
        @test result3[true] == "boolean"
        LuaNova.lua_pop!(L, 1)

        # Test nested tables
        LuaNova.safe_script(L, "dict4 = {outer = {inner = {deep = \"value\"}}}")
        LuaNova.get_global(L, "dict4")
        result4 = LuaNova.lua_table_to_dict(L, -1)
        @test isa(result4["outer"], Dict)
        @test isa(result4["outer"]["inner"], Dict)
        @test result4["outer"]["inner"]["deep"] == "value"
        LuaNova.lua_pop!(L, 1)

        # Test table with nil values
        LuaNova.safe_script(L, "dict5 = {a = 1, b = nil, c = 3}")
        LuaNova.get_global(L, "dict5")
        result5 = LuaNova.lua_table_to_dict(L, -1)
        @test result5["a"] == 1.0
        @test !haskey(result5, "b")  # nil values are not stored in Lua tables
        @test result5["c"] == 3.0
        LuaNova.lua_pop!(L, 1)

        # Test empty table
        LuaNova.safe_script(L, "dict6 = {}")
        LuaNova.get_global(L, "dict6")
        result6 = LuaNova.lua_table_to_dict(L, -1)
        @test length(result6) == 0
        LuaNova.lua_pop!(L, 1)

        LuaNova.close(L)
    end

    @testset "Error handling" begin
        L = LuaNova.new_state()
        LuaNova.open_libs(L)

        # Test lua_table_to_vector with non-table
        LuaNova.push_to_lua!(L, 42)
        @test_throws ErrorException LuaNova.lua_table_to_vector(L, -1)
        LuaNova.lua_pop!(L, 1)

        LuaNova.push_to_lua!(L, "not a table")
        @test_throws ErrorException LuaNova.lua_table_to_vector(L, -1)
        LuaNova.lua_pop!(L, 1)

        # Test lua_table_to_dict with non-table
        LuaNova.push_to_lua!(L, 42)
        @test_throws ErrorException LuaNova.lua_table_to_dict(L, -1)
        LuaNova.lua_pop!(L, 1)

        LuaNova.push_to_lua!(L, "not a table")
        @test_throws ErrorException LuaNova.lua_table_to_dict(L, -1)
        LuaNova.lua_pop!(L, 1)

        LuaNova.close(L)
    end

    @testset "Complex nested structures" begin
        L = LuaNova.new_state()
        LuaNova.open_libs(L)

        # Test array containing both arrays and objects
        LuaNova.safe_script(
            L,
            """
    complex = {
        {1, 2, 3},
        {name = "test", values = {4, 5, 6}},
        "simple string",
        42
    }
""",
        )
        LuaNova.get_global(L, "complex")
        result = LuaNova.lua_table_to_vector(L, -1)

        @test isa(result[1], Dict)  # First element is converted to dict
        @test result[1][1.0] == 1.0
        @test result[1][2.0] == 2.0
        @test result[1][3.0] == 3.0

        @test isa(result[2], Dict)
        @test result[2]["name"] == "test"
        @test isa(result[2]["values"], Dict)
        @test result[2]["values"][1.0] == 4.0

        @test result[3] == "simple string"
        @test result[4] == 42.0

        LuaNova.lua_pop!(L, 1)
        LuaNova.close(L)
    end
end

end
