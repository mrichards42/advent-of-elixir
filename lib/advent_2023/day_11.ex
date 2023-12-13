defmodule Advent2023.Day11 do
  @moduledoc """
  Day 11: Cosmic Expansion
  """

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {line, y} ->
      String.graphemes(line)
      |> Enum.with_index(1)
      |> Enum.map(fn {cell, x} -> {{x, y}, cell} end)
    end)
    |> Map.new()
  end

  def big_dimensions(grid) do
    max_x = Map.keys(grid) |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_y = Map.keys(grid) |> Enum.map(&elem(&1, 1)) |> Enum.max()

    big_xs =
      1..max_x |> Enum.filter(fn x -> Enum.all?(1..max_y, fn y -> grid[{x, y}] == "." end) end)

    big_ys =
      1..max_y |> Enum.filter(fn y -> Enum.all?(1..max_x, fn x -> grid[{x, y}] == "." end) end)

    {big_xs, big_ys}
  end

  def galaxies(grid) do
    grid
    |> Enum.filter(fn {_, cell} -> cell == "#" end)
    |> Enum.map(&elem(&1, 0))
  end

  def all_pairs([]) do
    []
  end

  def all_pairs([a | rest]) do
    Enum.map(rest, fn b -> {a, b} end) ++ all_pairs(rest)
  end

  def shortest_path_pairs(grid, expansion_factor) do
    {big_xs, big_ys} = big_dimensions(grid)

    for {{x1, y1}, {x2, y2}} <- all_pairs(galaxies(grid)) do
      x_range = min(x1, x2)..(max(x1, x2) - 1)//1
      y_range = min(y1, y2)..(max(y1, y2) - 1)//1

      dx =
        Range.size(x_range) +
          Enum.count(big_xs, &Enum.member?(x_range, &1)) * (expansion_factor - 1)

      dy =
        Range.size(y_range) +
          Enum.count(big_ys, &Enum.member?(y_range, &1)) * (expansion_factor - 1)

      dx + dy
    end
  end

  @doc """
  Part 1: Sum of distances between all pairs of galaxies (where empty spaces
  count for 2)

      iex> Advent2023.Day11.part1(Util.read_input!(2023, 11))
      9648398
  """
  def part1(input) do
    input
    |> parse_input()
    |> shortest_path_pairs(2)
    |> Enum.sum()
  end

  @doc """
  Part 2: Same, but using an expansion factor of 1 million

      iex> Advent2023.Day11.part2(Util.read_input!(2023, 11))
      618800410814
  """
  def part2(input) do
    input
    |> parse_input()
    |> shortest_path_pairs(1_000_000)
    |> Enum.sum()
  end
end
