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
    LuaNova.safe_script(L, "result = is_dict_type({})")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_boolean(L, -1) == true
    LuaNova.lua_pop!(L, 1)

    # Test table with string keys
    LuaNova.safe_script(L, "result = get_table_value({name='John', age=30}, 'name')")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_string(L, -1) == "John"
    LuaNova.lua_pop!(L, 1)

    LuaNova.safe_script(L, "result = get_table_value({name='John', age=30}, 'age')")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_number(L, -1) == 30.0
    LuaNova.lua_pop!(L, 1)

    # Test table with numeric keys
    LuaNova.safe_script(L, "result = get_table_value({10, 20, 30}, 1)")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_number(L, -1) == 10.0
    LuaNova.lua_pop!(L, 1)

    LuaNova.safe_script(L, "result = get_table_value({10, 20, 30}, 3)")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_number(L, -1) == 30.0
    LuaNova.lua_pop!(L, 1)

    # Test summing table values
    LuaNova.safe_script(L, "result = sum_table_values({a=1, b=2, c=3})")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_number(L, -1) == 6.0
    LuaNova.lua_pop!(L, 1)

    LuaNova.safe_script(L, "result = sum_table_values({10, 20, 30})")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_number(L, -1) == 60.0
    LuaNova.lua_pop!(L, 1)

    # Test counting table entries
    LuaNova.safe_script(L, "result = count_table_entries({a=1, b=2, c=3})")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_number(L, -1) == 3.0
    LuaNova.lua_pop!(L, 1)

    LuaNova.safe_script(L, "result = count_table_entries({})")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_number(L, -1) == 0.0
    LuaNova.lua_pop!(L, 1)

    # Test nested tables
    LuaNova.safe_script(L, "result = process_nested_table({nested={value=42}})")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_number(L, -1) == 42.0
    LuaNova.lua_pop!(L, 1)

    # Test table as one of multiple parameters
    LuaNova.safe_script(L, "result = accept_multiple_params(5, {x=10}, 3)")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_number(L, -1) == 18.0
    LuaNova.lua_pop!(L, 1)

    # Test mixed table (both array and hash parts)
    LuaNova.safe_script(L, "result = get_table_value({10, 20, name='test'}, 1)")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_number(L, -1) == 10.0
    LuaNova.lua_pop!(L, 1)

    LuaNova.safe_script(L, "result = get_table_value({10, 20, name='test'}, 'name')")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_string(L, -1) == "test"
    LuaNova.lua_pop!(L, 1)

    # Test haskey functionality
    LuaNova.safe_script(L, "result = has_key({a=1, b=2}, 'a')")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_boolean(L, -1) == true
    LuaNova.lua_pop!(L, 1)

    LuaNova.safe_script(L, "result = has_key({a=1, b=2}, 'c')")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_boolean(L, -1) == false
    LuaNova.lua_pop!(L, 1)

    # Test that tables are properly converted
    LuaNova.safe_script(L, "result = is_dict_type({x=10, y=20})")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_boolean(L, -1) == true
    LuaNova.lua_pop!(L, 1)

    # Test returning Dict from Julia to Lua
    LuaNova.safe_script(L, "result = return_dict()")
    LuaNova.get_global(L, "result")
    @test LuaNova.is_table(L, -1) == true
    result_dict = LuaNova.lua_table_to_dict(L, -1)
    @test result_dict["name"] == "Alice"
    @test result_dict["age"] == 25.0
    @test result_dict["score"] == 95.5
    LuaNova.lua_pop!(L, 1)

    # Test returning Vector from Julia to Lua
    LuaNova.safe_script(L, "result = return_vector()")
    LuaNova.get_global(L, "result")
    @test LuaNova.is_table(L, -1) == true
    result_vec = LuaNova.lua_table_to_vector(L, -1)
    @test result_vec[1] == 1.0
    @test result_vec[5] == 5.0
    @test length(result_vec) == 5
    LuaNova.lua_pop!(L, 1)

    # Test transforming a table (Lua -> Julia -> Lua)
    LuaNova.safe_script(L, "result = transform_table({a=10, b=20, c=30})")
    LuaNova.get_global(L, "result")
    @test LuaNova.is_table(L, -1) == true
    transformed = LuaNova.lua_table_to_dict(L, -1)
    @test transformed["A"] == 20.0
    @test transformed["B"] == 40.0
    @test transformed["C"] == 60.0
    LuaNova.lua_pop!(L, 1)

    # Test merging two tables
    LuaNova.safe_script(L, "result = merge_tables({a=1, b=2}, {c=3, d=4})")
    LuaNova.get_global(L, "result")
    @test LuaNova.is_table(L, -1) == true
    merged = LuaNova.lua_table_to_dict(L, -1)
    @test merged["a"] == 1.0
    @test merged["b"] == 2.0
    @test merged["c"] == 3.0
    @test merged["d"] == 4.0
    LuaNova.lua_pop!(L, 1)

    # Test merging with overlapping keys
    LuaNova.safe_script(L, "result = merge_tables({a=1, b=2}, {b=99, c=3})")
    LuaNova.get_global(L, "result")
    @test LuaNova.is_table(L, -1) == true
    merged2 = LuaNova.lua_table_to_dict(L, -1)
    @test merged2["a"] == 1.0
    @test merged2["b"] == 99.0
    @test merged2["c"] == 3.0
    LuaNova.lua_pop!(L, 1)

    LuaNova.close(L)

    return nothing
end

end
