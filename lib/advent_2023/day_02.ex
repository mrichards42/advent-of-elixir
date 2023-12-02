defmodule Advent2023.Day02 do
  @moduledoc """
  Day 2: Cube Conundrum
  """

  defmodule InputParser do
    import NimbleParsec
    import ParserUtil

    cube =
      empty()
      |> integer(min: 1)
      |> ignore(space())
      |> map(
        choice([string("red"), string("green"), string("blue")]),
        {String, :to_atom, []}
      )
      |> wrap()
      |> map({Enum, :reverse, []})
      |> map({List, :to_tuple, []})

    cubes =
      sep_by_1(cube, string(", "))
      |> wrap()
      |> map({Enum, :into, [%{red: 0, green: 0, blue: 0}]})

    game =
      empty()
      |> ignore(string("Game "))
      |> unwrap_and_tag(integer(min: 1), :id)
      |> ignore(string(": "))
      |> tag(sep_by_1(cubes, string("; ")), :rounds)
      |> ignore(eol_or_eos())
      |> wrap()
      |> map({Map, :new, []})

    defparser :parse, repeat_1(game)
  end

  def possible_game?(game) do
    Enum.all?(game.rounds, fn round ->
      round.red <= 12 and round.green <= 13 and round.blue <= 14
    end)
  end

  @doc """
  Part 1: Sum of possible games

      iex> Advent2023.Day02.part1(Util.read_input!(2023, 2))
      2101
  """
  def part1(input) do
    input
    |> InputParser.parse!()
    |> Enum.filter(&possible_game?/1)
    |> Enum.map(fn game -> game.id end)
    |> Enum.sum()
  end

  def min_cubes(game) do
    game.rounds
    |> Enum.flat_map(&Map.to_list/1)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Map.new(fn {color, counts} -> {color, Enum.max(counts)} end)
  end

  def score_min_cubes(cubes) do
    cubes.red * cubes.green * cubes.blue
  end

  @doc """
  Part 2: Math based on minimum required cubes per game

      iex> Advent2023.Day02.part2(Util.read_input!(2023, 2))
      58269
  """
  def part2(input) do
    input
    |> InputParser.parse!()
    |> Enum.map(&min_cubes/1)
    |> Enum.map(&score_min_cubes/1)
    |> Enum.sum()
  end
end
