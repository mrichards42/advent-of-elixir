defmodule Advent2023.Day08 do
  @moduledoc """
  Day 8: Haunted Wasteland
  """

  defmodule InputParser do
    import NimbleParsec
    import ParserUtil

    directions = repeat_1(ascii_char([?L, ?R])) |> wrap()

    map_line =
      ascii_string([?A..?Z, ?1..?9], 3)
      |> ignore(string(" = ("))
      |> ascii_string([?A..?Z, ?1..?9], 3)
      |> ignore(string(", "))
      |> ascii_string([?A..?Z, ?1..?9], 3)
      |> ignore(string(")") |> eol_or_eos())
      |> wrap()

    defparser :parse_raw, directions |> ignore(eol()) |> ignore(eol()) |> repeat_1(map_line)

    def parse!(input) do
      [directions | grid] = parse_raw!(input)
      {directions, Map.new(grid, fn [from, l, r] -> {from, {l, r}} end)}
    end
  end

  @doc """
  Part 1: Follow the directions from AAA to ZZZ

      iex> Advent2023.Day08.part1(Util.read_input!(2023, 8))
      19783
  """
  def part1(input) do
    {directions, grid} = InputParser.parse!(input)
    solve1(directions, grid, "AAA", &(&1 == "ZZZ"))
  end

  def solve1(directions, grid, start, stop?) do
    Stream.cycle(directions)
    |> Stream.scan(start, fn
      ?L, pos -> elem(grid[pos], 0)
      ?R, pos -> elem(grid[pos], 1)
    end)
    |> Enum.take_while(&(!stop?.(&1)))
    |> Enum.count()
    |> Util.inc()
  end

  @doc """
  Part 2: Anything ending with A is a start, ending with Z is an end. Find the
  point at which all paths end simultaneously.

      iex> Advent2023.Day08.part2(Util.read_input!(2023, 8))
      9177460370549
  """
  def part2(input) do
    {directions, grid} = InputParser.parse!(input)

    cycles =
      for start <- Map.keys(grid), String.ends_with?(start, "A") do
        solve1(directions, grid, start, &String.ends_with?(&1, "Z"))
      end

    # LCM doesn't necessarily work in the general case (I'm assuming that each
    # Z loops back to its starting A), but it does work for all the inputs in
    # AoC.
    Enum.reduce(cycles, &Math.lcm/2)
  end
end
