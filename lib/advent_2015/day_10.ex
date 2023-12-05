defmodule Advent2015.Day10 do
  @moduledoc """
  Day 10: Elves Look, Elves Say
  """

  def parse_input(input) do
    input
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Part 1: look-and-say sequence 40 iterations

      iex> Advent2015.Day10.part1(Util.read_input!(2015, 10))
      360154
  """
  def part1(input) do
    input
    |> parse_input()
    |> Stream.unfold(fn x -> {x, step(x)} end)
    |> Stream.drop(40)
    |> Enum.take(1)
    |> hd()
    |> length()
  end

  # According to wikipedia: No digits other than 1, 2, and 3 appear in the
  # sequence, unless the seed number contains such a digit or a run of more
  # than three of the same digit
  def step([]), do: []
  def step([1, 1, 1 | rest]), do: [3, 1 | step(rest)]
  def step([2, 2, 2 | rest]), do: [3, 2 | step(rest)]
  def step([3, 3, 3 | rest]), do: [3, 3 | step(rest)]
  def step([1, 1 | rest]), do: [2, 1 | step(rest)]
  def step([2, 2 | rest]), do: [2, 2 | step(rest)]
  def step([3, 3 | rest]), do: [2, 3 | step(rest)]
  def step([1 | rest]), do: [1, 1 | step(rest)]
  def step([2 | rest]), do: [1, 2 | step(rest)]
  def step([3 | rest]), do: [1, 3 | step(rest)]

  @doc """
  Part 2: look-and-say sequence 50 iterations

      iex> Advent2015.Day10.part2(Util.read_input!(2015, 10))
      5103798
  """
  def part2(input) do
    input
    |> parse_input()
    |> Stream.unfold(fn x -> {x, step(x)} end)
    |> Stream.drop(50)
    |> Enum.take(1)
    |> hd()
    |> length()
  end
end
