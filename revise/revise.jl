import Pkg
Pkg.instantiate()

using Revise

Pkg.activate(dirname(@__DIR__))
Pkg.instantiate()

using Lua
@info("""
This session is using Lua.jl with Revise.jl.
For more information visit https://timholy.github.io/Revise.jl/stable/.
""")
