module TestVectorAsParameter

using LuaNova
using Test

function is_vector_type(vec)
    return vec isa Vector
end
@define_lua_function is_vector_type

function get_vector_element(vec, index)
    return vec[Int(index)]
end
@define_lua_function get_vector_element

function sum_vector(vec)
    return sum(vec)
end
@define_lua_function sum_vector

function vector_length(vec)
    return length(vec)
end
@define_lua_function vector_length

function double_vector(vec)
    return vec .* 2
end
@define_lua_function double_vector

function accept_vector_and_scalar(scalar, vec, multiplier)
    return scalar + sum(vec) * multiplier
end
@define_lua_function accept_vector_and_scalar

function filter_positive(vec)
    return filter(x -> x > 0, vec)
end
@define_lua_function filter_positive

function vector_min_max(vec)
    return minimum(vec), maximum(vec)
end
@define_lua_function vector_min_max

function concatenate_vectors(v1, v2)
    return vcat(v1, v2)
end
@define_lua_function concatenate_vectors

function reverse_vector(vec)
    return reverse(vec)
end
@define_lua_function reverse_vector

@testset "Vector as parameter" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_function(L, "is_vector_type", is_vector_type)
    @push_lua_function(L, "get_vector_element", get_vector_element)
    @push_lua_function(L, "sum_vector", sum_vector)
    @push_lua_function(L, "vector_length", vector_length)
    @push_lua_function(L, "double_vector", double_vector)
    @push_lua_function(L, "accept_vector_and_scalar", accept_vector_and_scalar)
    @push_lua_function(L, "filter_positive", filter_positive)
    @push_lua_function(L, "vector_min_max", vector_min_max)
    @push_lua_function(L, "concatenate_vectors", concatenate_vectors)
    @push_lua_function(L, "reverse_vector", reverse_vector)

    # Test empty table (defaults to Dict, not Vector)
    LuaNova.safe_script(L, "result = is_vector_type({})")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_boolean(L, -1) == false
    LuaNova.lua_pop!(L, 1)

    # Test vector element access
    LuaNova.safe_script(L, "result = get_vector_element({10, 20, 30}, 1)")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_number(L, -1) == 10.0
    LuaNova.lua_pop!(L, 1)

    LuaNova.safe_script(L, "result = get_vector_element({10, 20, 30}, 3)")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_number(L, -1) == 30.0
    LuaNova.lua_pop!(L, 1)

    # Test sum of vector
    LuaNova.safe_script(L, "result = sum_vector({1, 2, 3, 4, 5})")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_number(L, -1) == 15.0
    LuaNova.lua_pop!(L, 1)

    # Test vector length
    LuaNova.safe_script(L, "result = vector_length({1, 2, 3})")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_number(L, -1) == 3.0
    LuaNova.lua_pop!(L, 1)

    LuaNova.safe_script(L, "result = vector_length({})")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_number(L, -1) == 0.0
    LuaNova.lua_pop!(L, 1)

    # Test vector transformation
    LuaNova.safe_script(L, "result = double_vector({1, 2, 3})")
    LuaNova.get_global(L, "result")
    @test LuaNova.is_table(L, -1) == true
    doubled = LuaNova.lua_table_to_vector(L, -1)
    @test doubled == [2.0, 4.0, 6.0]
    LuaNova.lua_pop!(L, 1)

    # Test vector as one of multiple parameters
    LuaNova.safe_script(L, "result = accept_vector_and_scalar(10, {1, 2, 3}, 2)")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_number(L, -1) == 22.0  # 10 + (1+2+3)*2
    LuaNova.lua_pop!(L, 1)

    # Test filtering vector
    LuaNova.safe_script(L, "result = filter_positive({-2, -1, 0, 1, 2, 3})")
    LuaNova.get_global(L, "result")
    @test LuaNova.is_table(L, -1) == true
    filtered = LuaNova.lua_table_to_vector(L, -1)
    @test filtered == [1.0, 2.0, 3.0]
    LuaNova.lua_pop!(L, 1)

    # Test multiple return values from vector operation
    LuaNova.safe_script(L, "min_val, max_val = vector_min_max({5, 2, 8, 1, 9, 3})")
    LuaNova.get_global(L, "min_val")
    @test LuaNova.to_number(L, -1) == 1.0
    LuaNova.lua_pop!(L, 1)
    LuaNova.get_global(L, "max_val")
    @test LuaNova.to_number(L, -1) == 9.0
    LuaNova.lua_pop!(L, 1)

    # Test concatenating vectors
    LuaNova.safe_script(L, "result = concatenate_vectors({1, 2, 3}, {4, 5, 6})")
    LuaNova.get_global(L, "result")
    @test LuaNova.is_table(L, -1) == true
    concatenated = LuaNova.lua_table_to_vector(L, -1)
    @test concatenated == [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
    LuaNova.lua_pop!(L, 1)

    # Test reversing a vector
    LuaNova.safe_script(L, "result = reverse_vector({1, 2, 3, 4, 5})")
    LuaNova.get_global(L, "result")
    @test LuaNova.is_table(L, -1) == true
    reversed = LuaNova.lua_table_to_vector(L, -1)
    @test reversed == [5.0, 4.0, 3.0, 2.0, 1.0]
    LuaNova.lua_pop!(L, 1)

    # Test that vector type is correctly identified
    LuaNova.safe_script(L, "result = is_vector_type({1, 2, 3})")
    LuaNova.get_global(L, "result")
    @test LuaNova.to_boolean(L, -1) == true
    LuaNova.lua_pop!(L, 1)

    LuaNova.close(L)

    return nothing
end

end
