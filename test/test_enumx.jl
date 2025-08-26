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

@enumx Direction North South East West
@define_lua_enumx Direction

function direction_name(dir::Direction.T)
    if dir == Direction.North
        return "north"
    elseif dir == Direction.South
        return "south"
    elseif dir == Direction.East
        return "east"
    elseif dir == Direction.West
        return "west"
    else
        error("Unknown direction")
    end
end
@define_lua_function direction_name

@testset "Enum" begin
    L = LuaNova.new_state()
    LuaNova.open_libs(L)

    @push_lua_enumx(L, Color)
    @push_lua_function(L, "color_name", color_name)
    
    @push_lua_enumx(L, Direction)
    @push_lua_function(L, "direction_name", direction_name)

    LuaNova.safe_script(
        L,
        """
red_color = Color.Red
green_color = Color.Green
blue_color = Color.Blue
        
red_name = color_name(red_color)
green_name = color_name(green_color)
blue_name = color_name(blue_color)

north = Direction.North
south = Direction.South
east = Direction.East
west = Direction.West

north_name = direction_name(north)
south_name = direction_name(south)
east_name = direction_name(east)
west_name = direction_name(west)
""",
    )

    LuaNova.get_global(L, "red_color")
    @test LuaNova.to_userdata(L, -1, Color.T) == Color.Red

    LuaNova.get_global(L, "green_color")
    @test LuaNova.to_userdata(L, -1, Color.T) == Color.Green

    LuaNova.get_global(L, "blue_color")
    @test LuaNova.to_userdata(L, -1, Color.T) == Color.Blue
    
    LuaNova.get_global(L, "red_name")
    @test LuaNova.to_string(L, -1) == "red"

    LuaNova.get_global(L, "green_name")
    @test LuaNova.to_string(L, -1) == "green"

    LuaNova.get_global(L, "blue_name")
    @test LuaNova.to_string(L, -1) == "blue"

    LuaNova.get_global(L, "north")
    @test LuaNova.to_userdata(L, -1, Direction.T) == Direction.North

    LuaNova.get_global(L, "south")
    @test LuaNova.to_userdata(L, -1, Direction.T) == Direction.South

    LuaNova.get_global(L, "east")
    @test LuaNova.to_userdata(L, -1, Direction.T) == Direction.East

    LuaNova.get_global(L, "west")
    @test LuaNova.to_userdata(L, -1, Direction.T) == Direction.West

    LuaNova.get_global(L, "north_name")
    @test LuaNova.to_string(L, -1) == "north"

    LuaNova.get_global(L, "south_name")
    @test LuaNova.to_string(L, -1) == "south"

    LuaNova.get_global(L, "east_name")
    @test LuaNova.to_string(L, -1) == "east"

    LuaNova.get_global(L, "west_name")
    @test LuaNova.to_string(L, -1) == "west"

    LuaNova.close(L)
end

end