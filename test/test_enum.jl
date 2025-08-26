module TestEnum

using EnumX
using LuaNova
using Test

@enumx Color Red Green Blue
@define_lua_enumx Color

function color_name(color::Color.T)
    if color == Color.Red
        return "red"
    elseif color == Color.Green
        return "green"
    elseif color == Color.Blue
        return "blue"
    else
        error("Unknown color")
    end
end
@define_lua_function color_name

@testset "Enum" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_enumx(L, Color)
    @push_lua_function(L, "color_name", color_name)

    LuaNova.safe_script(
        L,
        """
red_color = Color.Red
green_color = Color.Green
blue_color = Color.Blue
        
-- Test them
red_name = color_name(red_color)
green_name = color_name(green_color)
blue_name = color_name(blue_color)
        
print("Red: " .. red_name)
print("Green: " .. green_name) 
print("Blue: " .. blue_name)
        
assert(red_name == "red")
assert(green_name == "green")
assert(blue_name == "blue")
        
print("Color.Red works!")
""",
    )

    LuaNova.close(L)
end

@enumx Direction North South East West
@define_lua_enumx Direction

@testset "Multiple Enum" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_enumx(L, Color)
    @push_lua_enumx(L, Direction)

    LuaNova.safe_script(
        L,
        """
red = Color.Red
green = Color.Green
north = Direction.North
south = Direction.South
east = Direction.East
        
-- All should be userdata objects
assert(type(red) == "userdata")
assert(type(green) == "userdata")
assert(type(north) == "userdata") 
assert(type(south) == "userdata")
assert(type(east) == "userdata")
        
print("Multiple enums with dot notation work!")
print("Color.Red and Direction.North available!")
""",
    )

    LuaNova.close(L)
end

end