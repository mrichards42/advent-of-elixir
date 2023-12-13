defmodule Advent2023.Day12 do
  @moduledoc """
  Day 12: Hot Springs
  """

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      [springs, pattern] = String.split(line, " ")
      {springs, String.split(pattern, ",") |> Enum.map(&String.to_integer/1)}
    end)
  end

  defmodule Walk do
    use Memoize

    # This is basically a FSM with two states.
    defmemo in_block("." <> springs, [0 | rest]), do: waiting(springs, rest)
    defmemo in_block("." <> _, [_ | _]), do: 0
    defmemo in_block("#" <> _, [0 | _]), do: 0
    defmemo in_block("#" <> springs, [n | rest]), do: in_block(springs, [n - 1 | rest])

    defmemo in_block("?" <> springs, [0 | rest]), do: waiting(springs, rest)
    defmemo in_block("?" <> springs, [n | rest]), do: in_block(springs, [n - 1 | rest])

    defmemo in_block("", []), do: 1
    defmemo in_block("", [0]), do: 1
    defmemo in_block(_, _), do: 0

    defmemo waiting("." <> springs, pattern), do: waiting(springs, pattern)
    defmemo waiting("#" <> _, [0 | _]), do: 0
    defmemo waiting("#" <> springs, [n | rest]), do: in_block(springs, [n - 1 | rest])

    defmemo waiting("?" <> springs, [n | rest]) when n > 0 do
      waiting(springs, [n | rest]) + in_block(springs, [n - 1 | rest])
    end

    defmemo waiting("?" <> springs, pattern), do: waiting(springs, pattern)

    defmemo waiting("", []), do: 1
    defmemo waiting("", [0]), do: 1
    defmemo waiting(_, _), do: 0
  end

  @doc """
  Part 1: Number of possible arrangements, replacing ? with . or #

      iex> Advent2023.Day12.part1(Util.read_input!(2023, 12))
      7916
  """
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(fn {springs, pattern} -> Walk.waiting(springs, pattern) end)
    |> Enum.sum()
  end

  @doc """
  Part 2: Same thing but everything is 5x bigger

      iex> Advent2023.Day12.part2(Util.read_input!(2023, 12))
      37366887898686
  """
  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(fn {springs, pattern} ->
      {"#{springs}?#{springs}?#{springs}?#{springs}?#{springs}",
       pattern ++ pattern ++ pattern ++ pattern ++ pattern}
    end)
    |> Enum.map(fn {springs, pattern} -> Walk.waiting(springs, pattern) end)
    |> Enum.sum()
  end
end
