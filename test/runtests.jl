using LuaCall

using Aqua
using Test

include("aqua.jl")

function test_all()
    @testset "Aqua.jl" begin
        test_aqua()
    end

    return nothing
end

test_all()
