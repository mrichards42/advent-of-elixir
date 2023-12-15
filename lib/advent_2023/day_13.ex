defmodule Advent2023.Day13 do
  @moduledoc """
  Day 13: TITLE
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
  Part 1: DESCRIPTION

      iex> Advent2023.Day13.part1(Util.read_input!(2023, 13))
      35360
  """
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&hd(reflection_scores(&1)))
    |> Enum.sum()
  end

  def reflection_scores(map) do
    vertical = find_reflection(map)
    r_vertical = find_reflection(Enum.map(map, &Enum.reverse/1))
    horizontal = find_reflection(transpose(map))
    r_horizontal = find_reflection(transpose(Enum.reverse(map)))

    height = length(map)
    width = length(hd(map))

    # number of columns to the left/above the reflection line (horizontals * 100)
    Enum.filter(
      [
        vertical && width - vertical,
        r_vertical && r_vertical,
        horizontal && (height - horizontal) * 100,
        r_horizontal && r_horizontal * 100
      ],
      &Function.identity/1
    )
  end

  def transpose(lines), do: Enum.zip(lines) |> Enum.map(&Tuple.to_list/1)

  def find_reflection(lines) do
    line_count = length(lines)
    # Find the reflection point that exists in all lines
    lines
    |> Enum.flat_map(&line_reflections/1)
    |> Enum.frequencies()
    |> Enum.find_value(fn {mid, val} ->
      if val == line_count do
        mid
      end
    end)
  end

  def line_reflections([]), do: []

  def line_reflections(line) do
    len = length(line)

    if rem(len, 2) == 1 do
      line_reflections(tl(line))
    else
      mid = div(len, 2)
      {a, b} = Enum.split(line, mid)

      if a == Enum.reverse(b) do
        [mid | line_reflections(tl(tl(line)))]
      else
        line_reflections(tl(tl(line)))
      end
    end
  end

  @doc """
  Part 2: DESCRIPTION

      iex> Advent2023.Day13.part2(Util.read_input!(2023, 13))
      36755
  """
  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(&reflection_score_with_smudge/1)
    |> Enum.sum()
  end

  def unsmudge("#"), do: "."
  def unsmudge("."), do: "#"

  def reflection_score_with_smudge(map) do
    height = length(map)
    width = length(hd(map))
    flat = List.flatten(map)

    orig_scores = MapSet.new(reflection_scores(map))

    Stream.map(0..(width * height - 1), fn idx ->
      flat
      |> List.update_at(idx, &unsmudge/1)
      |> Enum.chunk_every(width)
    end)
    |> Enum.find_value(fn new_map ->
      new_scores = MapSet.new(reflection_scores(new_map))

      case MapSet.to_list(MapSet.difference(new_scores, orig_scores)) do
        [val] -> val
        _ -> nil
      end
    end)
  end
end
