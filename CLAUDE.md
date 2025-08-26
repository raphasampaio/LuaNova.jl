# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Testing
- Run all tests: `.\test\test.bat` or `julia +1.11 --project=. -e "import Pkg; Pkg.test()"`
- Run specific test: `.\test\test.bat test_functions.jl` (or any test file name)

### Formatting
- Format code: `.\format\format.bat` or `julia +1.11 --project=format format\format.jl`
- Formatting uses JuliaFormatter and must pass for CI

### Code Generation
- Regenerate C API bindings: `.\generator\generator.bat`
- This uses Clang.jl to generate `src/capi.jl` from Lua C headers

### Development Environment
- Interactive development with Revise: `.\revise\revise.bat`

## Code Architecture

### Core Components
- **src/LuaNova.jl**: Main module that exports key macros and functions
- **src/capi.jl**: Auto-generated Lua C API bindings (do not edit directly)
- **src/macros.jl**: Core macros `@define_lua_function`, `@define_lua_struct`, `@push_lua_function`, `@push_lua_struct`
- **src/state.jl**: Lua state management and data conversion functions
- **src/intermediate.jl**: Julia-to-Lua data conversion logic
- **src/registry.jl**: Function/struct registration system
- **src/error.jl**: Error handling for Lua operations

### Key Design Patterns
- **Macro-driven binding**: Functions and structs are exposed to Lua through macros that generate wrapper functions
- **C function generation**: `@cfunction` is used to create C-callable Julia functions for Lua integration
- **Type conversion**: Bidirectional conversion between Julia and Lua types via `from_lua()` and `push_to_lua!()`
- **Memory management**: Lua userdata with garbage collection for Julia objects

### Struct Binding System
When using `@define_lua_struct`, the macro generates:
- Constructor function callable from Lua
- `_index` function for property access
- `_newindex` function for property setting  
- `_gc` function for garbage collection
- Support for metamethods like `__add`, `__tostring`

### Function Multiple Dispatch
The `@define_lua_function` macro wraps Julia functions to handle multiple dispatch from Lua, automatically converting arguments and return values.