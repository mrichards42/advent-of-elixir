defmodule Advent2023.Day09 do
  @moduledoc """
  Day 9: Mirage Maintenance
  """

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line -> Enum.map(String.split(line, " "), &String.to_integer/1) end)
  end

  @doc """
  Part 1: Find the next number in each sequence

      iex> Advent2023.Day09.part1(Util.read_input!(2023, 9))
      1921197370
  """
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(fn line ->
      solve_sequence(line, [])
      |> Enum.map(&List.last/1)
      |> Enum.reduce(fn a, b -> a + b end)
    end)
    |> Enum.sum()
  end

  def solve_sequence(line, prev) do
    if Enum.all?(line, fn x -> x == 0 end) do
      [line | prev]
    else
      solve_sequence(Enum.zip_with(tl(line), line, fn x, y -> x - y end), [line | prev])
    end
  end

  @doc """
  Part 2: Same thing, but find the previous number in each sequence

      iex> Advent2023.Day09.part2(Util.read_input!(2023, 9))
      1124
  """
  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(fn line ->
      solve_sequence(line, [])
      |> Enum.map(&List.first/1)
      |> Enum.reduce(fn a, b -> a - b end)
    end)
    |> Enum.sum()
  end
end
