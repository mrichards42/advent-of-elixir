defmodule Advent2023.Day05 do
  @moduledoc """
  Day 5: If You Give A Seed A Fertilizer
  """

  alias BigGrid.BigGrid1D, as: Grid

  defmodule InputParser do
    import NimbleParsec
    import ParserUtil

    seeds =
      ignore(string("seeds: "))
      |> sep_by_1(integer(min: 1), space())
      |> ignore(eol())

    def reduce_mapping_line([dest, src, length]) do
      %{source_range: src..(src + length - 1), offset: dest - src}
    end

    mapping_line =
      sep_by_1(integer(min: 1), space())
      |> reduce(:reduce_mapping_line)

    map =
      empty()
      # we never actually use the label
      |> ignore(ascii_string([not: ?\s], min: 1))
      |> ignore(string(" map:\n"))
      |> repeat_1(mapping_line |> ignore(eol_or_eos()))
      |> wrap()

    input =
      tag(seeds, :seeds)
      |> ignore(eol())
      |> tag(repeat_1(map |> ignore(eol_or_eos())), :maps)
      |> reduce({Map, :new, []})

    defparser :parse, repeat_1(input)
  end

  @doc """
  Part 1: Closest location after translating seed to location

      iex> Advent2023.Day05.part1(Util.read_input!(2023, 5))
      579439039
  """
  def part1(input) do
    [%{seeds: seeds, maps: maps}] = InputParser.parse!(input)

    seeds
    |> Enum.map(fn seed -> Enum.reduce(maps, seed, &translate_step/2) end)
    |> Enum.min()
  end

  def translate_step(map, id) do
    Enum.find_value(map, id, fn %{source_range: source_range, offset: offset} ->
      if Enum.member?(source_range, id) do
        id + offset
      end
    end)
  end

  @doc """
  Part 2: Closest location after translating seed to location, but seeds are
  huge ranges

      iex> Advent2023.Day05.part2(Util.read_input!(2023, 5))
      7873084
  """
  def part2(input) do
    [%{seeds: seeds, maps: maps}] = InputParser.parse!(input)

    # Seed line now represents a (very large) range
    seed_ranges =
      seeds
      |> Enum.chunk_every(2)
      |> Enum.map(fn [start, len] -> start..(start + len - 1) end)

    # Time to pull out BigGrid since we're dealing with very large ranges. This
    # is a 1D grid that will hold seed ranges as they move through the maps.
    seed_grid = Grid.new(Enum.map(seed_ranges, fn r -> {r, 0} end))

    final_grid = Enum.reduce(maps, seed_grid, &translate_grid_step/2)

    # Grid regions are already sorted, so this is the minimum value
    [{min_val.._, _} | _] = Grid.regions(final_grid)
    min_val
  end

  def translate_grid_step(map, grid) do
    # 1. Track offsets for this step in a grid. At rest, seeds always have
    # value 0, so if any seeds do not match a mapping they will keep offset 0.
    grid_offsets =
      Enum.reduce(map, grid, fn %{source_range: source_range, offset: offset}, g ->
        Grid.update(g, source_range, nil, fn _ -> offset end)
      end)

    # 2. Nil values came from mapping ranges that did not correspond to an
    # actual seed
    seed_regions =
      Grid.regions(grid_offsets)
      |> Enum.reject(fn {_, offset} -> offset == nil end)

    # 3. Make a new grid by shifting existing seeds by the appropriate offset
    seed_regions
    |> Enum.map(fn {range, offset} -> {Range.shift(range, offset), 0} end)
    |> Grid.new()
  end
end
