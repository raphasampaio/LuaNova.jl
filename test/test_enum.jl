module TestEnum

using EnumX
using LuaNova
using Test

@enumx Color Red Green Blue
@define_lua_enumx Color

create_color() = Color.Red
@define_lua_function create_color

function color_name(color::Any)
    if color == Color.Red
        return "red"
    elseif color == Color.Green  
        return "green"
    elseif color == Color.Blue
        return "blue"
    else
        return "unknown"
    end
end
@define_lua_function color_name

@testset "Enum" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)
    
    # Register the enum metatable using the generated function
    register_Color_metatable(L)
    
    # Register Lua functions
    @push_lua_function(L, "create_color", create_color)
    @push_lua_function(L, "color_name", color_name)
    
    # Test creating and using enum values in Lua
    LuaNova.safe_script(
        L,
        """
        color = create_color()
        print(color)
        name = color_name(color)
        assert(name == "red")
        """
    )
    
    LuaNova.close(L)
end

# Test another enum to ensure the macro works for multiple enums
@enumx Direction North South East West
@define_lua_enumx Direction

create_direction() = Direction.North
@define_lua_function create_direction

@testset "Multiple Enum Test" begin 
    L = LuaNova.new_state()
    LuaNova.open_libs(L)
    
    # Register both enum metatables
    register_Color_metatable(L)
    register_Direction_metatable(L)
    
    @push_lua_function(L, "create_color", create_color)
    @push_lua_function(L, "create_direction", create_direction)
    
    LuaNova.safe_script(
        L,
        """
        color = create_color()
        direction = create_direction()  
        -- Both should be userdata objects
        assert(type(color) == "userdata")
        assert(type(direction) == "userdata")
        """
    )
    
    LuaNova.close(L)
end

end