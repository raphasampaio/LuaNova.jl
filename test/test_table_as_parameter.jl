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

@testset "Table as parameter" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_function(L, "get_table_type", get_table_type)
    @push_lua_function(L, "get_table_value", get_table_value)
    @push_lua_function(L, "sum_table_values", sum_table_values)
    @push_lua_function(L, "count_table_entries", count_table_entries)
    @push_lua_function(L, "process_nested_table", process_nested_table)
    @push_lua_function(L, "accept_multiple_params", accept_multiple_params)
    @push_lua_function(L, "return_table_keys", return_table_keys)

    # Test empty table
    @test LuaNova.safe_script(L, "assert(get_table_type({}) == 'Dict{Any, Any}')") === nothing

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

    LuaNova.close(L)

    return nothing
end

end
