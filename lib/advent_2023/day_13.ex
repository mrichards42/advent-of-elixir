defmodule Advent2023.Day13 do
  @moduledoc """
  Day 13: Point of Incidence
  """

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(fn block ->
      block
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)
    end)
  end

  @doc """
  Part 1: Find the reflection point in each block

      iex> Advent2023.Day13.part1(Util.read_input!(2023, 13))
      35360
  """
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&hd(reflection_scores(&1)))
    |> Enum.sum()
  end

  def reflection_scores(grid) do
    horizontals = find_reflections(grid)
    verticals = find_reflections(transpose(grid))

    verticals ++ Enum.map(horizontals, &(&1 * 100))
  end

  def transpose(lines), do: Enum.zip(lines) |> Enum.map(&Tuple.to_list/1)

  def find_reflections(lines) do
    count = length(lines)
    mid = div(count, 2)

    Enum.filter(1..(count - 1), fn idx ->
      {a, b} = Enum.split(lines, idx)

      if idx > mid do
        List.starts_with?(Enum.reverse(a), b)
      else
        List.starts_with?(b, Enum.reverse(a))
      end
    end)
  end

  @doc """
  Part 2: Find the *new* reflection point in each block after flipping one cell

      iex> Advent2023.Day13.part2(Util.read_input!(2023, 13))
      36755
  """
  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&reflection_score_with_smudge/1)
    |> Enum.sum()
  end

  def smudge("#"), do: "."
  def smudge("."), do: "#"

  def reflection_score_with_smudge(grid) do
    orig_scores = MapSet.new(reflection_scores(grid))

    height = length(grid)
    width = length(hd(grid))
    flat_grid = List.flatten(grid)

    grids_with_smudges =
      Stream.map(0..(width * height - 1), fn idx ->
        flat_grid
        |> List.update_at(idx, &smudge/1)
        |> Enum.chunk_every(width)
      end)

    Enum.find_value(grids_with_smudges, fn smuged_grid ->
      smudged_scores = MapSet.new(reflection_scores(smuged_grid))
      Enum.at(MapSet.difference(smudged_scores, orig_scores), 0, nil)
    end)
  end
end
