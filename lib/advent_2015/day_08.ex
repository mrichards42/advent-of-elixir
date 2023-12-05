defmodule Advent2015.Day08 do
  @moduledoc """
  Day 8: Matchsticks
  """

  def quote_string(str),
    do: inspect(str, limit: :infinity, printable_limit: :infinity)

  def unquote_string(str),
    do: Code.string_to_quoted!(str)

  @doc """
  Part 1: Difference between quoted and evaluated string lengths

      iex> Advent2015.Day08.part1(Util.read_input!(2015, 8))
      1371
  """
  def part1(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x -> String.length(x) - String.length(unquote_string(x)) end)
    |> Enum.sum()
  end

  @doc """
  Part 2: Difference between quoted and twice-quoted string lengths

      iex> Advent2015.Day08.part2(Util.read_input!(2015, 8))
      2117
  """
  def part2(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x -> String.length(quote_string(x)) - String.length(x) end)
    |> Enum.sum()
  end
end
