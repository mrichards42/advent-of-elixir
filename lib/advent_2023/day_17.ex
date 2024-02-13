defmodule Advent2023.Day17 do
  @moduledoc """
  Day 17: Clumsy Crucible
  """

  def parse_input(input) do
    lines = input |> String.trim() |> String.split("\n")

    for {line, y} <- Enum.with_index(lines),
        {cell, x} <- Enum.with_index(String.graphemes(line)) do
      {{x + 1, y + 1}, String.to_integer(cell)}
    end
    |> Map.new()
  end

  @doc """
  Part 1: Path through the city that minimizes heat loss.

      iex> Advent2023.Day17.part1(Util.read_input!(2023, 17))
      635
  """
  def part1(input) do
    grid = input |> parse_input()
    {gx, gy} = Enum.max(Map.keys(grid))
    start = {1, 1, :X, 1}
    goals = for dir <- [:N, :S, :E, :w], steps <- 1..3, do: {gx, gy, dir, steps}

    neighbors_fn = fn {x, y, dir, steps} ->
      for {d2, s2} <- allowed_moves({dir, steps}) do
        {x2, y2} = move({x, y}, d2)
        {x2, y2, d2, s2}
      end
      |> Enum.filter(fn {x, y, _, _} -> grid[{x, y}] end)
    end

    cost_fn = fn _, {x2, y2, _, _} -> grid[{x2, y2}] end
    [{min_cost, _}] = Pathfinding.dijkstra(start, goals, neighbors_fn, cost_fn, goal: :first)
    min_cost
  end

  def allowed_moves({:E, 3}), do: [{:N, 1}, {:S, 1}]
  def allowed_moves({:E, n}), do: [{:N, 1}, {:S, 1}, {:E, n + 1}]
  def allowed_moves({:W, 3}), do: [{:N, 1}, {:S, 1}]
  def allowed_moves({:W, n}), do: [{:N, 1}, {:S, 1}, {:W, n + 1}]
  def allowed_moves({:N, 3}), do: [{:E, 1}, {:W, 1}]
  def allowed_moves({:N, n}), do: [{:E, 1}, {:W, 1}, {:N, n + 1}]
  def allowed_moves({:S, 3}), do: [{:E, 1}, {:W, 1}]
  def allowed_moves({:S, n}), do: [{:E, 1}, {:W, 1}, {:S, n + 1}]

  def allowed_moves({:X, _}), do: [{:E, 1}, {:W, 1}, {:S, 1}, {:N, 1}]

  def move(pos, dir, n \\ 1)
  def move({x, y}, :N, n), do: {x, y - n}
  def move({x, y}, :S, n), do: {x, y + n}
  def move({x, y}, :E, n), do: {x + n, y}
  def move({x, y}, :W, n), do: {x - n, y}

  @doc """
  Part 2: Same but different rules about min/max steps before a turn.

      iex> Advent2023.Day17.part2(Util.read_input!(2023, 17))
      734
  """
  def part2(input) do
    grid = input |> parse_input()
    {gx, gy} = Enum.max(Map.keys(grid))
    start = {1, 1, :X, 0}
    goals = for dir <- [:N, :S, :E, :w], steps <- 4..9, do: {gx, gy, dir, steps}

    neighbors_fn = fn {x, y, dir, steps} ->
      for {d2, s2} <- allowed_moves_2({dir, steps}) do
        if s2 == 0 do
          # move 4 spaces instead of 4 separate moves
          {x2, y2} = move({x, y}, d2, 4)
          {x2, y2, d2, 3}
        else
          {x2, y2} = move({x, y}, d2)
          {x2, y2, d2, s2}
        end
      end
      |> Enum.filter(fn {x, y, _, _} -> grid[{x, y}] end)
    end

    cost_fn = fn {x1, y1, _, _}, {x2, y2, _, _} ->
      Enum.sum(for x <- x1..x2, y <- y1..y2, {x, y} != {x1, y1}, do: grid[{x, y}])
    end

    [{min_cost, _}] = Pathfinding.dijkstra(start, goals, neighbors_fn, cost_fn, goal: :first)
    min_cost
  end

  # TODO: graph compression instead of separate min/max steps
  def allowed_moves_2({:X, _}), do: [{:E, 0}, {:W, 0}, {:S, 0}, {:N, 0}]
  def allowed_moves_2({dir, n}) when n < 3, do: [{dir, n + 1}]
  def allowed_moves_2({:E, 9}), do: [{:N, 0}, {:S, 0}]
  def allowed_moves_2({:E, n}), do: [{:N, 0}, {:S, 0}, {:E, n + 1}]
  def allowed_moves_2({:W, 9}), do: [{:N, 0}, {:S, 0}]
  def allowed_moves_2({:W, n}), do: [{:N, 0}, {:S, 0}, {:W, n + 1}]
  def allowed_moves_2({:N, 9}), do: [{:E, 0}, {:W, 0}]
  def allowed_moves_2({:N, n}), do: [{:E, 0}, {:W, 0}, {:N, n + 1}]
  def allowed_moves_2({:S, 9}), do: [{:E, 0}, {:W, 0}]
  def allowed_moves_2({:S, n}), do: [{:E, 0}, {:W, 0}, {:S, n + 1}]
end
