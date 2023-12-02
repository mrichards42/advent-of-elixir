defmodule Advent2015.Day05 do
  @moduledoc """
  Day 5: Doesn't He Have Intern-Elves For This?
  """

  def vowel_count(str), do: Regex.scan(~r/[aeiou]/, str) |> Enum.count()
  def double_letter?(str), do: str =~ ~r/(.)\1/
  def no_bad_strings?(str), do: not (str =~ ~r/ab|cd|pq|xy/)

  def nice_string_1?(str) do
    vowel_count(str) >= 3 and double_letter?(str) and no_bad_strings?(str)
  end

  @doc """
  Part 1: Nice strings

      iex> Advent2015.Day05.part1(Util.read_input!(2015, 5))
      258
  """
  def part1(input) do
    input
    |> String.split()
    |> Enum.count(&nice_string_1?/1)
  end

  def double_double?(str), do: str =~ ~r/(..).*\1/
  def aba?(str), do: str =~ ~r/(.).\1/

  def nice_string_2?(str), do: double_double?(str) and aba?(str)

  @doc """
  Part 2: Different method

      iex> Advent2015.Day05.part2(Util.read_input!(2015, 5))
      53
  """
  def part2(input) do
    input
    |> String.split()
    |> Enum.count(&nice_string_2?/1)
  end
end
