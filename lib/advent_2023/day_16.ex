defmodule Advent2023.Day16 do
  @moduledoc """
  Day 16: The Floor Will Be Lava
  """

  def parse_input(input) do
    lines = input |> String.trim() |> String.split("\n")

    # 1-indexed grids since vim counts rows and cols starting from 1, so I can
    # use the cursor to find tiles
    for {line, y} <- Enum.with_index(lines, 1),
        {cell, x} <- Enum.with_index(String.graphemes(line), 1) do
      {{x, y}, cell}
    end
    |> Map.new()
  end

  @doc """
  Part 1: Shine the beam of light from the top left and count how many tiles
  are energized

      iex> Advent2023.Day16.part1(Util.read_input!(2023, 16))
      6740
  """
  def part1(input) do
    grid = input |> parse_input()

    shine_beam(grid, {0, 1, :E})
  end

  def shine_beam(grid, start) do
    beam_step(grid, [start], MapSet.new())
    |> Enum.uniq_by(fn {x, y, _} -> {x, y} end)
    |> Enum.count()
    # -1 for the initial tile which is outside the grid
    |> Util.dec()
  end

  # The beam can split, so rather than tracking the single point that is the
  # end of the beam of light, we track a list of heads

  def beam_step(grid, heads, seen) do
    next_seen = Enum.reduce(heads, seen, fn h, seen -> MapSet.put(seen, h) end)

    next_heads =
      heads
      |> Enum.flat_map(&step(grid, &1))
      |> Enum.reject(&Enum.member?(next_seen, &1))

    if Enum.empty?(next_heads) do
      next_seen
    else
      beam_step(grid, next_heads, next_seen)
    end
  end

  def move({x, y, :E}), do: {x + 1, y}
  def move({x, y, :W}), do: {x - 1, y}
  def move({x, y, :N}), do: {x, y - 1}
  def move({x, y, :S}), do: {x, y + 1}

  def next_dir(:E, "."), do: [:E]
  def next_dir(:E, "-"), do: [:E]
  def next_dir(:E, "\\"), do: [:S]
  def next_dir(:E, "/"), do: [:N]
  def next_dir(:E, "|"), do: [:N, :S]
  def next_dir(:W, "."), do: [:W]
  def next_dir(:W, "-"), do: [:W]
  def next_dir(:W, "\\"), do: [:N]
  def next_dir(:W, "/"), do: [:S]
  def next_dir(:W, "|"), do: [:N, :S]
  def next_dir(:N, "."), do: [:N]
  def next_dir(:N, "-"), do: [:E, :W]
  def next_dir(:N, "\\"), do: [:W]
  def next_dir(:N, "/"), do: [:E]
  def next_dir(:N, "|"), do: [:N]
  def next_dir(:S, "."), do: [:S]
  def next_dir(:S, "-"), do: [:E, :W]
  def next_dir(:S, "\\"), do: [:E]
  def next_dir(:S, "/"), do: [:W]
  def next_dir(:S, "|"), do: [:S]
  # off the grid
  def next_dir(_, nil), do: []

  def step(grid, {x1, y1, dir1}) do
    {x2, y2} = move({x1, y1, dir1})

    for dir2 <- next_dir(dir1, Map.get(grid, {x2, y2})) do
      {x2, y2, dir2}
    end
  end

  @doc """
  Part 2: Shine the beam from every edge tile and see which one results in the
  greatest number of energized tiles

      iex> Advent2023.Day16.part2(Util.read_input!(2023, 16))
      7041
  """
  def part2(input) do
    grid = input |> parse_input()

    {min_x, max_x} = Enum.min_max(for {{x, _}, _} <- grid, do: x)
    {min_y, max_y} = Enum.min_max(for {{_, y}, _} <- grid, do: y)

    Enum.max([
      # top
      Enum.max(for x <- min_x..max_x, do: shine_beam(grid, {x, min_y - 1, :S})),
      # bottom
      Enum.max(for x <- min_x..max_x, do: shine_beam(grid, {x, max_y + 1, :N})),
      # left
      Enum.max(for y <- min_y..max_y, do: shine_beam(grid, {min_x - 1, y, :E})),
      # right
      Enum.max(for y <- min_y..max_y, do: shine_beam(grid, {max_x + 1, y, :W}))
    ])
  end
end
