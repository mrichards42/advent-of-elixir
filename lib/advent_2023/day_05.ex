defmodule Advent2023.Day05 do
  @moduledoc """
  Day 5: If You Give A Seed A Fertilizer
  """

  def parse_input(input) do
    [seed_line | maps] = input |> String.trim() |> String.split("\n\n")
    seeds = seed_line |> String.split(" ") |> Enum.drop(1) |> Enum.map(&String.to_integer/1)

    maps =
      maps
      |> Enum.map(&String.split(&1, "\n"))
      |> Enum.map(fn [label | lines] ->
        {hd(String.split(label, " ")),
         lines
         |> Enum.map(fn line ->
           line |> String.split(" ") |> Enum.map(&String.to_integer/1)
         end)}
      end)

    {seeds, maps}
  end

  def translate(mapping, id) do
    Enum.find_value(mapping, id, fn [to, from, count] ->
      offset = id - from

      if offset >= 0 and offset < count do
        to + offset
      end
    end)
  end

  @doc """
  Part 1: Closest location after translating seed to location

      iex> Advent2023.Day05.part1(Util.read_input!(2023, 5))
      579439039
  """
  def part1(input) do
    {seeds, maps} = input |> parse_input() |> dbg

    seeds
    |> Enum.map(fn seed -> Enum.reduce(maps, seed, fn {_, map}, id -> translate(map, id) end) end)
    |> Enum.min()
  end

  @doc """
  Part 2: Closest location after translating seed to location, but seeds are
  huge ranges

      iex> Advent2023.Day05.part2(Util.read_input!(2023, 5))
      7873084
  """
  def part2(input) do
    {seeds, maps} = input |> parse_input()

    seed_ranges =
      Enum.chunk_every(seeds, 2) |> Enum.map(fn [start, len] -> start..(start + len - 1) end)

    alias BigGrid.BigGrid1D, as: Grid
    # vals are offsets from the original(?)
    init_grid = Grid.new(Enum.map(seed_ranges, fn r -> {r, 0} end))

    final_grid =
    Enum.reduce(maps, init_grid, fn {_, map}, grid ->
      new_grid =
        Enum.reduce(map, grid, fn [to, from, len], g ->
          Grid.update(g, from..(from + len - 1), nil, fn _ -> to - from end)
        end)

      # now we have a mapping of {range, offset} . . . turn this into
      # {range+offset, 0}
      Grid.regions(new_grid)
      |> Enum.reject(fn {_, offset} -> offset == nil end)
      |> Enum.map(fn {range, offset} -> {Range.shift(range, offset), 0} end)
      |> Grid.new()
    end)

    [{min_val.._, 0} | _] = Grid.regions(final_grid)
    min_val
  end
end
