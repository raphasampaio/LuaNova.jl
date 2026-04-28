module TestLuaSideMethods

using LuaNova
using Test

mutable struct Container
    x::Float64
end
@define_lua_struct Container

@testset "Lua-side method extension" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_struct(L, Container)

    LuaNova.safe_script(L, """
        function Container.scale(self, factor)
            self.x = self.x * factor
        end
        c = Container(5.0)
        c:scale(3.0)
    """)
    LuaNova.safe_script(L, "return c.x")
    @test LuaNova.to_number(L, -1) == 15.0

    LuaNova.close(L)
    return nothing
end

end
