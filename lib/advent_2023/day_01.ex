defmodule Advent2023.Day01 do
  @moduledoc """
  Day 1: Trebuchet?!
  """

  def parse_input(input, digit_parser) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      digits = digit_parser.(line)
      Enum.at(digits, 0) <> Enum.at(digits, -1)
    end)
    |> Enum.map(&String.to_integer/1)
  end

  def parse_digits1(line) do
    Regex.scan(~r/\d/, line) |> Enum.map(&hd/1)
  end

  @doc """
  Part 1: first and last digits in each line

      iex> Advent2023.Day01.part1(Util.read_input!(2023, 1))
      54644
  """
  def part1(input) do
    input
    |> parse_input(&parse_digits1/1)
    |> Enum.sum()
  end

  @string_digits %{
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9"
  }

  def parse_digits2(line) do
    # lookahead plus capture to get overlapping matches
    Regex.scan(~r/(?=(\d|one|two|three|four|five|six|seven|eight|nine))/, line)
    |> Enum.map(&hd(tl(&1)))
    |> Enum.map(&Map.get(@string_digits, &1, &1))
  end

  @doc """
  Part 2: digits can also be spelled out

      iex> Advent2023.Day01.part2(Util.read_input!(2023, 1))
      53348
  """
  def part2(input) do
    input
    |> parse_input(&parse_digits2/1)
    |> Enum.sum()
  end
end
