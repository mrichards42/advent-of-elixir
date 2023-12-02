defmodule Advent2015.Day01 do
  @moduledoc """
  Day 1: Not Quite Lisp
  """

  defmodule InputParser do
    import NimbleParsec
    import ParserUtil

    paren =
      choice([
        ascii_char(~c"(") |> replace(1),
        ascii_char(~c")") |> replace(-1)
      ])

    defparser :parse, repeat(paren) |> ignore(eol_or_eos())
  end

  @doc """
  Part 1: Final floor

      iex> Advent2015.Day01.part1(Util.read_input!(2015, 1))
      232
  """
  def part1(input) do
    input
    |> InputParser.parse!()
    |> Enum.sum()
  end

  @doc """
  Part 2: First instruction that puts you in the basement

      iex> Advent2015.Day01.part2(Util.read_input!(2015, 1))
      1783
  """
  def part2(input) do
    input
    |> InputParser.parse!()
    |> Enum.scan(&+/2)
    |> Enum.take_while(&(&1 >= 0))
    |> Enum.count()
    |> Util.inc()
  end
end
