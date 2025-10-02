module TestTableAsParameter

using LuaNova
using Test

function is_dict_type(table)
    return table isa Dict
end
@define_lua_function is_dict_type

function get_table_value(table, key)
    return table[key]
end
@define_lua_function get_table_value

function sum_table_values(table)
    total = 0.0
    for (k, v) in table
        if v isa Number
            total += v
        end
    end
    return total
end
@define_lua_function sum_table_values

function count_table_entries(table)
    return length(table)
end
@define_lua_function count_table_entries

function process_nested_table(table)
    return table["nested"]["value"]
end
@define_lua_function process_nested_table

function accept_multiple_params(a, table, b)
    return a + table["x"] + b
end
@define_lua_function accept_multiple_params

function has_key(table, key)
    return haskey(table, key)
end
@define_lua_function has_key

function return_dict()
    return Dict("name" => "Alice", "age" => 25, "score" => 95.5)
end
@define_lua_function return_dict

function return_vector()
    return [1, 2, 3, 4, 5]
end
@define_lua_function return_vector

function transform_table(table)
    result = Dict{String, Any}()
    for (k, v) in table
        if k isa String
            result[uppercase(k)] = v isa Number ? v * 2 : v
        end
    end
    return result
end
@define_lua_function transform_table

function merge_tables(t1, t2)
    result = Dict{Any, Any}()
    for (k, v) in t1
        result[k] = v
    end
    for (k, v) in t2
        result[k] = v
    end
    return result
end
@define_lua_function merge_tables

@testset "Table as parameter" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_function(L, "is_dict_type", is_dict_type)
    @push_lua_function(L, "get_table_value", get_table_value)
    @push_lua_function(L, "sum_table_values", sum_table_values)
    @push_lua_function(L, "count_table_entries", count_table_entries)
    @push_lua_function(L, "process_nested_table", process_nested_table)
    @push_lua_function(L, "accept_multiple_params", accept_multiple_params)
    @push_lua_function(L, "has_key", has_key)
    @push_lua_function(L, "return_dict", return_dict)
    @push_lua_function(L, "return_vector", return_vector)
    @push_lua_function(L, "transform_table", transform_table)
    @push_lua_function(L, "merge_tables", merge_tables)

    # Test empty table
    @test LuaNova.safe_script(L, "assert(is_dict_type({}))") === nothing

    # Test table with string keys
    @test LuaNova.safe_script(L, "assert(get_table_value({name='John', age=30}, 'name') == 'John')") === nothing
    @test LuaNova.safe_script(L, "assert(get_table_value({name='John', age=30}, 'age') == 30)") === nothing

    # Test table with numeric keys
    @test LuaNova.safe_script(L, "assert(get_table_value({10, 20, 30}, 1) == 10)") === nothing
    @test LuaNova.safe_script(L, "assert(get_table_value({10, 20, 30}, 3) == 30)") === nothing

    # Test summing table values
    @test LuaNova.safe_script(L, "assert(sum_table_values({a=1, b=2, c=3}) == 6)") === nothing
    @test LuaNova.safe_script(L, "assert(sum_table_values({10, 20, 30}) == 60)") === nothing

    # Test counting table entries
    @test LuaNova.safe_script(L, "assert(count_table_entries({a=1, b=2, c=3}) == 3)") === nothing
    @test LuaNova.safe_script(L, "assert(count_table_entries({}) == 0)") === nothing

    # Test nested tables
    @test LuaNova.safe_script(L, "assert(process_nested_table({nested={value=42}}) == 42)") === nothing

    # Test table as one of multiple parameters
    @test LuaNova.safe_script(L, "assert(accept_multiple_params(5, {x=10}, 3) == 18)") === nothing

    # Test mixed table (both array and hash parts)
    @test LuaNova.safe_script(L, "assert(get_table_value({10, 20, name='test'}, 1) == 10)") === nothing
    @test LuaNova.safe_script(L, "assert(get_table_value({10, 20, name='test'}, 'name') == 'test')") === nothing

    # Test haskey functionality
    @test LuaNova.safe_script(L, "assert(has_key({a=1, b=2}, 'a'))") === nothing
    @test LuaNova.safe_script(L, "assert(not has_key({a=1, b=2}, 'c'))") === nothing

    # Test that tables are properly converted
    @test LuaNova.safe_script(L, "assert(is_dict_type({x=10, y=20}))") === nothing

    # Test returning Dict from Julia to Lua
    @test LuaNova.safe_script(
        L,
        """
    local t = return_dict()
    assert(type(t) == 'table')
    assert(t.name == 'Alice')
    assert(t.age == 25)
    assert(t.score == 95.5)
""",
    ) === nothing

    # Test returning Vector from Julia to Lua
    @test LuaNova.safe_script(
        L,
        """
    local arr = return_vector()
    assert(type(arr) == 'table')
    assert(arr[1] == 1)
    assert(arr[5] == 5)
    assert(#arr == 5)
""",
    ) === nothing

    # Test transforming a table (Lua -> Julia -> Lua)
    @test LuaNova.safe_script(
        L,
        """
    local result = transform_table({a=10, b=20, c=30})
    assert(result.A == 20)
    assert(result.B == 40)
    assert(result.C == 60)
""",
    ) === nothing

    # Test merging two tables
    @test LuaNova.safe_script(
        L,
        """
    local result = merge_tables({a=1, b=2}, {c=3, d=4})
    assert(result.a == 1)
    assert(result.b == 2)
    assert(result.c == 3)
    assert(result.d == 4)
""",
    ) === nothing

    # Test merging with overlapping keys
    @test LuaNova.safe_script(
        L,
        """
    local result = merge_tables({a=1, b=2}, {b=99, c=3})
    assert(result.a == 1)
    assert(result.b == 99)
    assert(result.c == 3)
""",
    ) === nothing

    LuaNova.close(L)

    return nothing
end

end
