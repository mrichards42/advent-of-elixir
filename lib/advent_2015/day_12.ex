defmodule Advent2015.Day12 do
  @moduledoc """
  Day 12: JSAbacusFramework.io
  """

  @doc """
  Part 1: Sum of all numbers in the json input

      iex> Advent2015.Day12.part1(Util.read_input!(2015, 12))
      119433
  """
  def part1(input) do
    input
    |> Jason.decode!()
    |> sum_numbers()
  end

  def sum_numbers([x | rest]), do: sum_numbers(x) + sum_numbers(rest)
  def sum_numbers(%{} = m), do: sum_numbers(Map.values(m))
  def sum_numbers(x) when is_integer(x), do: x
  def sum_numbers(_), do: 0

  @doc """
  Part 2: Remove all objects with a "red" value first

      iex> Advent2015.Day12.part2(Util.read_input!(2015, 12))
      68466
  """
  def part2(input) do
    input
    |> Jason.decode!()
    |> strip_red()
    |> sum_numbers()
  end

  def strip_red(%{} = m) do
    if Enum.any?(m, fn {_, v} -> v == "red" end) do
      %{}
    else
      Enum.into(m, %{}, fn {k, v} -> {k, strip_red(v)} end)
    end
  end

  def strip_red([x | rest]), do: [strip_red(x) | strip_red(rest)]

  def strip_red(x), do: x
end
