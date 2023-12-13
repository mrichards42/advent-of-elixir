defmodule Advent2023.Day10 do
  @moduledoc """
  Day 10: Pipe Maze
  """
  require Integer

  def parse_input(input) do
    for {line, y} <- Enum.with_index(String.split(input, "\n"), 1),
        {cell, x} <- Enum.with_index(String.graphemes(line), 1) do
      {{x, y}, cell}
    end
    |> Map.new()
  end

  @doc """
  Part 1: Find the point in the loop the farthest distance from start

      iex> Advent2023.Day10.part1(Util.read_input!(2023, 10))
      7086
  """
  def part1(input) do
    grid = parse_input(input)
    path = walk(grid, [])
    div(length(path), 2)
  end

  def neighbors({{x, y}, "-"}), do: [{x - 1, y}, {x + 1, y}]
  def neighbors({{x, y}, "|"}), do: [{x, y - 1}, {x, y + 1}]
  def neighbors({{x, y}, "L"}), do: [{x, y - 1}, {x + 1, y}]
  def neighbors({{x, y}, "J"}), do: [{x, y - 1}, {x - 1, y}]
  def neighbors({{x, y}, "7"}), do: [{x, y + 1}, {x - 1, y}]
  def neighbors({{x, y}, "F"}), do: [{x, y + 1}, {x + 1, y}]
  def neighbors(_), do: []

  def neighbor_cells(cell, grid), do: neighbors(cell) |> Enum.map(&{&1, grid[&1]})

  def find_start(grid) do
    Enum.find(grid, fn
      {_, "S"} -> true
      _ -> false
    end)
  end

  def start_neighbors(grid, {{x, y}, _} = start) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    |> Enum.map(&{&1, grid[&1]})
    |> Enum.filter(fn cell ->
      Enum.any?(neighbor_cells(cell, grid), &(&1 == start))
    end)
  end

  def walk(grid, []) do
    start = find_start(grid)
    # start has 2 neighbors, but we only need to move in one direction
    [neighbor, _] = start_neighbors(grid, start)
    walk(grid, [neighbor, start])
  end

  def walk(grid, [current, prev | _] = path) do
    next =
      current
      |> neighbor_cells(grid)
      |> Enum.find(&(&1 != prev))

    case next do
      nil -> path
      # we've reached start again, we're done
      {_, "S"} -> path
      cell -> walk(grid, [cell | path])
    end
  end

  @doc """
  Part 2: Find the area enclosed by the loop

      iex> Advent2023.Day10.part2(Util.read_input!(2023, 10))
      317
  """
  def part2(input) do
    grid = input |> parse_input()
    path = walk(grid, [])
    path_map = Map.new(replace_start_pipe(grid, path))
    {min_y, max_y} = Enum.min_max(for {{_, y}, _} <- path_map, do: y)
    Enum.sum(for y <- min_y..max_y, do: even_odd_rule_line(path_map, y))
  end

  def replace_start_pipe(grid, [a | path]) do
    # the loop runs a(first) -> start(last) -> b -> rest
    [{start_pos, _}, b | rest] = Enum.reverse(path)

    start_shape =
      Enum.find(["-", "|", "7", "F", "J", "L"], fn shape ->
        neighbors = neighbor_cells({start_pos, shape}, grid)
        Enum.member?(neighbors, a) and Enum.member?(neighbors, b)
      end)

    # this ends up reversing the path and starting from a instead of start, but
    # since it's a loop it doesn't matter
    [a, {start_pos, start_shape}, b | rest]
  end

  def even_odd_rule_line(path_map, y) do
    {min_x, max_x} = Enum.min_max(for {{x, ^y}, _} <- path_map, do: x)

    {_, total_count} =
      Enum.reduce(min_x..max_x, {0, 0}, fn x, {crossings, count} ->
        pipe_part = path_map[{x, y}]

        inc_count =
          if pipe_part == nil and Integer.is_odd(crossings), do: 1, else: 0

        inc_crossing =
          case pipe_part do
            # unchanged if not in path
            nil -> 0
            # vertical pipes flip
            "|" -> 1
            # All other pipes are partially on the line itself. We treat these
            # as if they were slightly below the line for intersection
            # purposes, so for pipes connecting north, that means flip, and for
            # all other pipes that means no change.
            "L" -> 1
            "J" -> 1
            "7" -> 0
            "F" -> 0
            "-" -> 0
          end

        {crossings + inc_crossing, count + inc_count}
      end)

    total_count
  end
end
