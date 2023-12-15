defmodule Advent2023.Day14 do
  @moduledoc """
  Day 14: Parabolic Reflector Dish
  """

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  @doc """
  Part 1: Score rocks after rolling them to the north

      iex> Advent2023.Day14.part1(Util.read_input!(2023, 14))
      108641
  """
  def part1(input) do
    input
    |> parse_input()
    |> roll_north()
    |> score_grid()
  end

  def score_grid(grid) do
    grid
    |> transpose()
    |> Enum.map(&score_col/1)
    |> Enum.sum()
  end

  def roll_north(grid) do
    transpose(grid)
    |> Enum.map(&roll_col/1)
    |> transpose()
  end

  def roll_col(["." | rest]) do
    case Enum.split_while(rest, &(&1 == ".")) do
      {dots, []} -> ["." | dots]
      # block ends a section of empty space
      {dots, ["#" | more]} -> ["." | dots] ++ ["#" | roll_col(more)]
      # rock rolls to the front
      {dots, ["O" | more]} -> ["O" | roll_col(["." | dots ++ more])]
    end
  end

  def roll_col([fst | rest]), do: [fst | roll_col(rest)]
  def roll_col([]), do: []

  def transpose(lines), do: Enum.zip(lines) |> Enum.map(&Tuple.to_list/1)

  def score_col(["O" | rest] = col), do: length(col) + score_col(rest)
  def score_col([_ | rest]), do: score_col(rest)
  def score_col([]), do: 0

  @doc """
  Part 2: Score rocks after doing 1 billion full spin cycles (NWSE)

      iex> Advent2023.Day14.part2(Util.read_input!(2023, 14))
      84328
  """
  def part2(input) do
    {grid, [a, b]} =
      input
      |> parse_input()
      |> find_spin_cycle()
      |> Enum.max_by(fn {_, vals} -> length(vals) end)

    cycle_len = a - b
    extra_cycles = rem(1_000_000_000 - b, cycle_len)

    1..extra_cycles
    |> Enum.reduce(grid, fn _, g -> spin(g) end)
    |> score_grid()
  end

  def find_spin_cycle(grid) do
    Stream.iterate(grid, &spin/1)
    |> Stream.with_index()
    |> Enum.reduce_while(%{}, fn {g, idx}, seen ->
      if seen[g] do
        {:halt, Map.update!(seen, g, fn prev -> [idx | prev] end)}
      else
        {:cont, Map.put(seen, g, [idx])}
      end
    end)
  end

  def spin(grid) do
    grid |> roll_north() |> roll_west() |> roll_south() |> roll_east()
  end

  def roll_west(grid) do
    Enum.map(grid, &roll_col/1)
  end

  def roll_south(grid) do
    grid
    |> transpose()
    |> Enum.map(fn col -> Enum.reverse(col) |> roll_col() |> Enum.reverse() end)
    |> transpose()
  end

  def roll_east(grid) do
    grid |> Enum.map(fn col -> Enum.reverse(col) |> roll_col() |> Enum.reverse() end)
  end
end
