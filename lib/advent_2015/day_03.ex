defmodule Advent2015.Day03 do
  @moduledoc """
  Day 3: Perfectly Spherical Houses in a Vacuum
  """

  defmodule InputParser do
    import NimbleParsec
    import ParserUtil

    direction =
      choice([
        string("^") |> replace(:up),
        string("v") |> replace(:down),
        string("<") |> replace(:left),
        string(">") |> replace(:right)
      ])

    defparser :parse, repeat(direction) |> ignore(eol_or_eos())
  end

  def run_sleigh(directions) do
    Enum.scan(directions, {0, 0}, fn direction, {x, y} ->
      case direction do
        :up -> {x, y - 1}
        :down -> {x, y + 1}
        :left -> {x - 1, y}
        :right -> {x + 1, y}
      end
    end)
  end

  @doc """
  Part 1: Number of houses visited

      iex> Advent2015.Day03.part1(Util.read_input!(2015, 3))
      2572
  """
  def part1(input) do
    input
    |> InputParser.parse!()
    |> run_sleigh()
    |> Enum.uniq()
    |> Enum.count()
  end

  @doc """
  Part 2: Split directions into two groups

      iex> Advent2015.Day03.part2(Util.read_input!(2015, 3))
      2631
  """
  def part2(input) do
    directions = InputParser.parse!(input)
    santa = Enum.take_every(directions, 2)
    robo_santa = Enum.take_every(Enum.drop(directions, 1), 2)

    (run_sleigh(santa) ++ run_sleigh(robo_santa))
    |> Enum.uniq()
    |> Enum.count()
  end
end
