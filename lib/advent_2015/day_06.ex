defmodule Advent2015.Day06 do
  @moduledoc """
  Day 6: Probably a Fire Hazard
  """

  # The naive version of this (each light is a separate point in the grid)
  # takes over 30 seconds for each part. Using this space-efficient grid gets
  # it down to < 1 second.
  alias BigGrid.BigGrid2D, as: Grid

  defmodule InputParser do
    import NimbleParsec
    import ParserUtil

    coord =
      sep_by(integer(min: 1), string(","), 2)
      |> reduce({List, :to_tuple, []})

    line =
      unwrap_and_tag(
        choice([string("turn on"), string("turn off"), string("toggle")]),
        :type
      )
      |> ignore(space())
      |> unwrap_and_tag(coord, :top_left)
      |> ignore(string(" through "))
      |> unwrap_and_tag(coord, :bottom_right)
      |> ignore(eol_or_eos())
      |> reduce({Map, :new, []})

    defparser :parse, repeat(line)
  end

  @doc """
  Part 1: Number of lights on after following instructions

      iex> Advent2015.Day06.part1(Util.read_input!(2015, 6))
      377891
  """
  def part1(input) do
    input
    |> InputParser.parse!()
    |> Enum.reduce(Grid.new(), &run_instruction_1/2)
    |> Grid.regions()
    |> Enum.map(fn
      {coords, true} -> Grid.region_size(coords)
      {_, false} -> 0
    end)
    |> Enum.sum()
  end

  def instruction_range(%{top_left: {x1, y1}, bottom_right: {x2, y2}}) do
    {x1..x2//1, y1..y2//1}
  end

  def run_instruction_1(%{type: "turn on"} = instruction, grid) do
    Grid.put(grid, instruction_range(instruction), true)
  end

  def run_instruction_1(%{type: "turn off"} = instruction, grid) do
    Grid.put(grid, instruction_range(instruction), false)
  end

  def run_instruction_1(%{type: "toggle"} = instruction, grid) do
    Grid.update(grid, instruction_range(instruction), true, &!/1)
  end

  @doc """
  Part 2: Brightness after following different instructions

      iex> Advent2015.Day06.part2(Util.read_input!(2015, 6))
      14110788
  """
  def part2(input) do
    input
    |> InputParser.parse!()
    |> Enum.reduce(Grid.new(), &run_instruction_2/2)
    |> Grid.regions()
    |> Enum.map(fn {coords, val} -> Grid.region_size(coords) * val end)
    |> Enum.sum()
  end

  def run_instruction_2(%{type: "turn on"} = instruction, grid) do
    Grid.update(grid, instruction_range(instruction), 1, fn x -> x + 1 end)
  end

  def run_instruction_2(%{type: "turn off"} = instruction, grid) do
    Grid.update(grid, instruction_range(instruction), 0, fn x -> max(0, x - 1) end)
  end

  def run_instruction_2(%{type: "toggle"} = instruction, grid) do
    Grid.update(grid, instruction_range(instruction), 2, fn x -> x + 2 end)
  end
end
