defmodule Advent2015.Day01 do
  @moduledoc """
  Day 1: Not Quite Lisp
  """

  defmodule Parser do
    import NimbleParsec
    import ParserUtil

    paren =
      choice([
        ascii_char(~c"(") |> replace(1),
        ascii_char(~c")") |> replace(-1)
      ])

    defparsec :parser, repeat(paren) |> ignore(eol_or_eos())
  end

  def parse_input(input) do
    input
    |> ParserUtil.parse!(&Parser.parser/1)
  end

  @doc """
  Part 1: Final floor

      iex> Advent2015.Day01.part1(Util.read_input!(2015, 1))
      232
  """
  def part1(input) do
    input
    |> parse_input()
    |> Enum.sum()
  end

  @doc """
  Part 2: First instruction that puts you in the basement

      iex> Advent2015.Day01.part2(Util.read_input!(2015, 1))
      1783
  """
  def part2(input) do
    input
    |> parse_input()
    |> Enum.scan(&+/2)
    |> Enum.take_while(&(&1 >= 0))
    |> Enum.count()
    |> Util.inc()
  end
end
