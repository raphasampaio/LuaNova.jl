module TestStandardLibrary

using LuaNova
using Test

@testset "Standard Library" begin
    @testset "Individual Library Opening" begin
        L = LuaNova.new_state()

        LuaNova.open_math_lib(L)

        LuaNova.safe_script(L, "result = math.sin(1.0)")
        LuaNova.get_global(L, "result")
        @test LuaNova.to_number(L, -1) ≈ sin(1.0)

        LuaNova.close(L)
    end

    @testset "String Library" begin
        L = LuaNova.new_state()
        LuaNova.open_base_lib(L)
        LuaNova.open_string_lib(L)

        LuaNova.safe_script(L, "result = string.upper('hello')")
        LuaNova.get_global(L, "result")
        @test LuaNova.to_string(L, -1) == "HELLO"

        LuaNova.close(L)
    end

    @testset "Table Library" begin
        L = LuaNova.new_state()
        LuaNova.open_base_lib(L)
        LuaNova.open_table_lib(L)

        LuaNova.safe_script(
            L,
            """
    t = {3, 1, 4, 1, 5}
    table.sort(t)
    result = table.concat(t, ',')
""",
        )
        LuaNova.get_global(L, "result")
        @test LuaNova.to_string(L, -1) == "1,1,3,4,5"

        LuaNova.close(L)
    end

    @testset "OS Library" begin
        L = LuaNova.new_state()
        LuaNova.open_base_lib(L)
        LuaNova.open_os_lib(L)

        LuaNova.safe_script(L, "result = os.time()")
        LuaNova.get_global(L, "result")
        current_time = LuaNova.to_number(L, -1)
        @test current_time > 0

        LuaNova.close(L)
    end

    @testset "UTF-8 Library" begin
        L = LuaNova.new_state()
        LuaNova.open_base_lib(L)
        LuaNova.open_utf8_lib(L)

        LuaNova.safe_script(L, "result = utf8.len('Hello 🌍')")
        LuaNova.get_global(L, "result")
        @test LuaNova.to_number(L, -1) == 7

        LuaNova.close(L)
    end

    @testset "Package Library" begin
        L = LuaNova.new_state()
        LuaNova.open_base_lib(L)
        LuaNova.open_package_lib(L)

        LuaNova.safe_script(L, "result = type(package)")
        LuaNova.get_global(L, "result")
        @test LuaNova.to_string(L, -1) == "table"

        LuaNova.close(L)
    end

    @testset "Coroutine Library" begin
        L = LuaNova.new_state()
        LuaNova.open_base_lib(L)
        LuaNova.open_coroutine_lib(L)

        LuaNova.safe_script(
            L,
            """
    co = coroutine.create(function() 
        coroutine.yield(42)
        return 84
    end)
    success, result = coroutine.resume(co)
""",
        )
        LuaNova.get_global(L, "result")
        @test LuaNova.to_number(L, -1) == 42

        LuaNova.close(L)
    end

    @testset "Base Library" begin
        L = LuaNova.new_state()
        LuaNova.open_base_lib(L)

        LuaNova.safe_script(L, "result = type(42)")
        LuaNova.get_global(L, "result")
        @test LuaNova.to_string(L, -1) == "number"

        LuaNova.safe_script(L, "result = tostring(123)")
        LuaNova.get_global(L, "result")
        @test LuaNova.to_string(L, -1) == "123"

        LuaNova.close(L)
    end

    @testset "Debug Library" begin
        L = LuaNova.new_state()
        LuaNova.open_base_lib(L)
        LuaNova.open_debug_lib(L)

        LuaNova.safe_script(L, "result = type(debug)")
        LuaNova.get_global(L, "result")
        @test LuaNova.to_string(L, -1) == "table"

        LuaNova.safe_script(
            L,
            """
    function test_func() end
    info = debug.getinfo(test_func)
    result = info.what
""",
        )
        LuaNova.get_global(L, "result")
        @test LuaNova.to_string(L, -1) == "Lua"

        LuaNova.close(L)
    end

    @testset "Open All Libraries" begin
        L = LuaNova.new_state()
        LuaNova.open_libs(L)

        test_scripts = [
            ("math.sin(1)", sin(1.0)),
            ("string.upper('test')", "TEST"),
            ("type(42)", "number"),
        ]

        for (script, expected) in test_scripts
            LuaNova.safe_script(L, "result = $script")
            LuaNova.get_global(L, "result")
            if expected isa String
                @test LuaNova.to_string(L, -1) == expected
            else
                @test LuaNova.to_number(L, -1) ≈ expected
            end
        end

        LuaNova.close(L)
    end

    @testset "Multiple Libraries Integration" begin
        L = LuaNova.new_state()
        LuaNova.open_base_lib(L)
        LuaNova.open_math_lib(L)
        LuaNova.open_string_lib(L)
        LuaNova.open_table_lib(L)

        LuaNova.safe_script(
            L,
            """
    -- Use math and string libraries together
    local result = {}
    for i = 1, 5 do
        result[i] = string.format("%.2f", math.sin(i))
    end
    final_result = table.concat(result, ", ")
""",
        )
        LuaNova.get_global(L, "final_result")
        result_string = LuaNova.to_string(L, -1)
        @test occursin("0.84", result_string)
        @test occursin("0.91", result_string)

        LuaNova.close(L)
    end

    @testset "Library Error Handling" begin
        L = LuaNova.new_state()

        @test_throws LuaError LuaNova.safe_script(L, "result = math.sin(1)")

        LuaNova.close(L)
    end

    @testset "IO Library" begin
        L = LuaNova.new_state()
        LuaNova.open_base_lib(L)
        LuaNova.open_io_lib(L)

        LuaNova.safe_script(L, "result = type(io)")
        LuaNova.get_global(L, "result")
        @test LuaNova.to_string(L, -1) == "table"

        LuaNova.safe_script(L, "result = type(io.write)")
        LuaNova.get_global(L, "result")
        @test LuaNova.to_string(L, -1) == "function"

        LuaNova.close(L)
    end
end

end
