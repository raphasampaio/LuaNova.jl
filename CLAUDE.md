# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

**Testing:**
- Run all tests: `julia --project -e "import Pkg; Pkg.test()"`
- Run specific test file: `julia --project test/runtests.jl test_filename.jl`
- Convenient test scripts: `test/test.bat` (Windows) or `test/test.sh` (Unix)

**Code Formatting:**
- Format code: `format/format.bat` (Windows) or `format/format.sh` (Unix)
- Uses JuliaFormatter to enforce consistent code style

**Package Management:**
- Activate project environment: `julia --project`
- Install dependencies: `julia --project -e "import Pkg; Pkg.instantiate()"`

## Architecture Overview

LuaNova.jl is a Julia package that embeds a Lua interpreter and provides bidirectional interoperability between Julia and Lua. The architecture consists of:

**Core Components:**
- `src/c_api.jl` - Low-level C bindings to Lua C API via Lua_jll
- `src/state.jl` - Lua state management and lifecycle functions
- `src/macros.jl` - Key macros `@define_lua_function`, `@define_lua_struct`, `@push_lua_function`, `@push_lua_struct`
- `src/intermediate.jl` - Type conversion between Julia and Lua
- `src/registry.jl` - Function and struct registration system
- `src/error.jl` - Error handling and `LuaError` type
- `src/util.jl` - Utility functions for type conversions
- `src/stdlib.jl` - Standard library functions

**Key Design Patterns:**
- Uses macro-based registration system for exposing Julia functions/structs to Lua
- Function dispatch through Julia's multiple dispatch system exposed to Lua
- Struct metamethods (`__add`, `__tostring`, etc.) supported via Julia methods
- Type-safe conversions between Julia and Lua types
- Registry system tracks registered functions/structs per Lua state

**Dependencies:**
- `Lua_jll` for Lua C library bindings
- `EnumX` for enhanced enum support

The package supports both mutable and immutable structs, varargs functions, multiple return values, and comprehensive error handling with stack traces.