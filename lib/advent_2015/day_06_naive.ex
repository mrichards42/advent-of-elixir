defmodule Advent2015.Day06Naive do
  @moduledoc """
  Day 6: Probably a Fire Hazard
  """

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

  # TODO: this is ridiculously slow, like 30 seconds
  def coord_seq(%{top_left: {x1, y1}, bottom_right: {x2, y2}}) do
    for x <- x1..x2, y <- y1..y2, do: {x, y}
  end

  @doc """
  Part 1: Number of lights on after following instructions

      iex> Advent2015.Day06Naive.part1(Util.read_input!(2015, 6))
      377891
  """
  def part1(input) do
    input
    |> InputParser.parse!()
    |> Enum.reduce(%{}, &run_instruction_1/2)
    |> Enum.count(fn {_, state} -> state end)
  end

  def run_instruction_1(%{type: "turn on"} = instruction, grid) do
    for coord <- coord_seq(instruction), into: grid do
      {coord, true}
    end
  end

  def run_instruction_1(%{type: "turn off"} = instruction, grid) do
    for coord <- coord_seq(instruction), into: grid do
      {coord, false}
    end
  end

  def run_instruction_1(%{type: "toggle"} = instruction, grid) do
    for coord <- coord_seq(instruction), into: grid do
      {coord, not Map.get(grid, coord, false)}
    end
  end

  @doc """
  Part 2: Brightness after following different instructions

      iex> Advent2015.Day06Naive.part2(Util.read_input!(2015, 6))
      14110788
  """
  def part2(input) do
    input
    |> InputParser.parse!()
    |> Enum.reduce(%{}, &run_instruction_2/2)
    |> Enum.reduce(0, fn {_, brightness}, total -> total + brightness end)
  end

  def run_instruction_2(%{type: "turn on"} = instruction, grid) do
    for coord <- coord_seq(instruction), into: grid do
      {coord, Map.get(grid, coord, 0) + 1}
    end
  end

  def run_instruction_2(%{type: "turn off"} = instruction, grid) do
    for coord <- coord_seq(instruction), into: grid do
      {coord, max(0, Map.get(grid, coord, 0) - 1)}
    end
  end

  def run_instruction_2(%{type: "toggle"} = instruction, grid) do
    for coord <- coord_seq(instruction), into: grid do
      {coord, Map.get(grid, coord, 0) + 2}
    end
  end
end
