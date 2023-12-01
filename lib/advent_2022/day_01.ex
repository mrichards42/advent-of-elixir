defmodule Advent2022.Day01 do
  @moduledoc """
  Day 1: Calorie Counting
  """

  defmodule Parser do
    import NimbleParsec
    import ParserUtil

    block =
      many_1(integer(min: 1) |> ignore(eol_or_eos()))

    file =
      many_1(block |> wrap() |> ignore(eol_or_eos()))

    defparsec :parser, file
  end

  def parse_input(input) do
    input
    |> ParserUtil.parse!(&Parser.parser/1)
  end

  @doc """
  Part 1: Elf with the most calories

      iex> Advent2022.Day01.part1(Util.read_input!(2022, 1))
      69795
  """
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&Enum.sum/1)
    |> Enum.max()
  end

  @doc """
  Part 2: Sum of top 3 elves

      iex> Advent2022.Day01.part2(Util.read_input!(2022, 1))
      208437
  """
  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&Enum.sum/1)
    |> Enum.sort()
    |> Enum.slice(-3..-1)
    |> Enum.sum()
  end
end
