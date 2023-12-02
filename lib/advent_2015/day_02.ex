defmodule Advent2015.Day02 do
  @moduledoc """
  Day 2: I Was Told There Would Be No Math
  """

  defmodule InputParser do
    import NimbleParsec
    import ParserUtil

    line =
      empty()
      |> unwrap_and_tag(integer(min: 1), :l)
      |> ignore(string("x"))
      |> unwrap_and_tag(integer(min: 1), :w)
      |> ignore(string("x"))
      |> unwrap_and_tag(integer(min: 1), :h)
      |> reduce({Map, :new, []})

    defparser :parse, repeat(line |> ignore(eol_or_eos()))
  end

  def calc_wrapping_paper(%{l: l, w: w, h: h}) do
    sides = [l * w, w * h, h * l]
    Enum.sum(sides) * 2 + Enum.min(sides)
  end

  @doc """
  Part 1: Total wrapping paper needed

      iex> Advent2015.Day02.part1(Util.read_input!(2015, 2))
      1598415
  """
  def part1(input) do
    input
    |> InputParser.parse!()
    |> Enum.map(&calc_wrapping_paper/1)
    |> Enum.sum()
  end

  def calc_ribbon(%{l: l, w: w, h: h}) do
    ribbon = Enum.min([2 * l + 2 * w, 2 * w + 2 * h, 2 * h + 2 * l])
    bow = l * w * h
    ribbon + bow
  end

  @doc """
  Part 2: Total ribbon needed

      iex> Advent2015.Day02.part2(Util.read_input!(2015, 2))
      3812909
  """
  def part2(input) do
    input
    |> InputParser.parse!()
    |> Enum.map(&calc_ribbon/1)
    |> Enum.sum()
  end
end
