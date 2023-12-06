defmodule Advent2023.Day06 do
  @moduledoc """
  Day 6: Wait For It
  """

  @doc """
  Part 1: Number of ways you can beat the record for each race

      iex> Advent2023.Day06.part1(Util.read_input!(2023, 6))
      2612736
  """
  def part1(input) do
    input
    |> parse_input1()
    |> Enum.map(fn {time, record} ->
      all_options(time) |> Enum.count(fn total -> total > record end)
    end)
    |> Enum.product()
  end

  def parse_input1(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line -> Regex.scan(~r/\d+/, line) |> Enum.map(&String.to_integer(hd(&1))) end)
    |> Enum.zip()
  end

  def all_options(total_time) do
    Enum.map(0..total_time, fn hold_time -> (total_time - hold_time) * hold_time end)
  end

  @doc """
  Part 2: Smash all the numbers together into a single race and try again

  I brute-forced this (it only took a few seconds) and then went back and wrote
  the binary search.

      iex> Advent2023.Day06.part2(Util.read_input!(2023, 6))
      29891250
  """
  def part2(input) do
    input
    |> parse_input2()
    |> Enum.map(fn {time, record} -> binary_search_options(time, record) end)
    |> Enum.product()
  end

  def parse_input2(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      Regex.scan(~r/\d+/, line) |> List.flatten() |> Enum.join("") |> String.to_integer()
    end)
    |> List.to_tuple()
    |> List.wrap()
  end

  def binary_search_options(total_time, record) do
    pivot = binary_search_start(total_time, record, 0, ceil(total_time / 2))
    # double-check, it's possible we can't ever beat the record
    score = (total_time - pivot) * pivot

    if score > record do
      # The result is symmetric, so we just need to find the pivot where you
      # first beat the record, and then you can beat the record from pivot
      # through total-pivot
      Enum.count(pivot..(total_time - pivot))
    else
      0
    end
  end

  def binary_search_start(total_time, record, low, high) do
    mid = ceil((high + low) / 2)
    score = (total_time - mid) * mid

    cond do
      low == high -> low
      score >= record and mid == high -> mid
      score < record and mid == low -> mid + 1
      score > record -> binary_search_start(total_time, record, low, mid)
      score < record -> binary_search_start(total_time, record, mid, high)
    end
  end
end
