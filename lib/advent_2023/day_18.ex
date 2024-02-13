defmodule Advent2023.Day18 do
  @moduledoc """
  Day 18: Lavaduct Lagoon
  """

  require Integer

  defmodule InputParser do
    import NimbleParsec
    import ParserUtil

    line =
      ascii_char([?R, ?L, ?U, ?D])
      |> ignore(space())
      |> integer(min: 1)
      |> ignore(string(" (#"))
      |> map(ascii_string([?0..?9, ?a..?f], 5), {String, :to_integer, [16]})
      |> map(ascii_string([?0..?9, ?a..?f], 1), {String, :to_integer, [16]})
      |> ignore(string(")"))
      |> wrap()

    defparser :parse, repeat_1(line |> ignore(eol_or_eos()))
  end

  @doc """
  Part 1: Follow the instructions and determine the size of the hole

      iex> Advent2023.Day18.part1(Util.read_input!(2023, 18))
      72821
  """
  def part1(input) do
    {grid, _} =
      input
      |> InputParser.parse!()
      |> Enum.reduce({Map.new([{{1, 1}, "#"}]), {1, 1}}, &step/2)

    # debugging the grid with a pixmap
    # File.write!(
    #   "day18.pbm",
    #   Util.pixmap(grid, fn grid, point -> grid[point] == "#" end)
    # )

    {min_y, max_y} = Enum.min_max(for {{_, y}, _} <- grid, do: y)
    Enum.sum(for y <- min_y..max_y, do: even_odd_fill(grid, y))
  end

  # Part 2 code also works for part 1, but this is how I did it originally

  def step([?U, n | _], {grid, {x, y}}) do
    grid2 =
      Enum.reduce(1..n, grid, fn dy, g -> Map.put_new(g, {x, y - dy}, "#") end)

    {grid2, {x, y - n}}
  end

  def step([?D, n | _], {grid, {x, y}}) do
    grid2 =
      Enum.reduce(1..n, grid, fn dy, g -> Map.put_new(g, {x, y + dy}, "#") end)

    {grid2, {x, y + n}}
  end

  def step([?L, n | _], {grid, {x, y}}) do
    grid2 =
      Enum.reduce(1..n, grid, fn dx, g -> Map.put_new(g, {x - dx, y}, "#") end)

    {grid2, {x - n, y}}
  end

  def step([?R, n | _], {grid, {x, y}}) do
    grid2 =
      Enum.reduce(1..n, grid, fn dx, g -> Map.put_new(g, {x + dx, y}, "#") end)

    {grid2, {x + n, y}}
  end

  def even_odd_fill(grid, y) do
    {min_x, max_x} = Enum.min_max(for {{x, ^y}, _} <- grid, do: x)

    {_, total_count} =
      Enum.reduce(min_x..max_x, {0, 0}, fn x, {crossings, count} ->
        filled? = grid[{x, y}] == "#"

        inc_count =
          if filled? or Integer.is_odd(crossings), do: 1, else: 0

        inc_crossing =
          cond do
            !filled? -> 0
            # do we have a crossing above this point?
            grid[{x, y - 1}] == "#" -> 1
            true -> 0
          end

        {crossings + inc_crossing, count + inc_count}
      end)

    total_count
  end

  alias BigGrid.BigGrid2D, as: Grid

  @doc """
  Part 2: Same thing but the distances are huge

      iex> Advent2023.Day18.part2(Util.read_input!(2023, 18))
      127844509405501
  """
  def part2(input) do
    init_grid =
      Grid.new()
      |> Grid.put({-99_999_999..99_999_999, -99_999_999..99_999_999}, ".")
      |> Grid.put({1..1, 1..1}, "#")

    {grid, _} =
      input
      |> InputParser.parse!()
      |> Enum.map(&parse_instruction_2/1)
      |> Enum.reduce({init_grid, {1, 1}}, &step_2/2)

    grid
    |> Grid.regions()
    |> Enum.map(fn {{xrange, _}, _} -> xrange end)
    |> Enum.uniq()
    |> Enum.map(fn xrange -> even_odd_fill_region(grid, xrange) end)
    |> Enum.sum()
  end

  def parse_instruction_2([_, _, dist, 0]), do: [?R, dist]
  def parse_instruction_2([_, _, dist, 1]), do: [?D, dist]
  def parse_instruction_2([_, _, dist, 2]), do: [?L, dist]
  def parse_instruction_2([_, _, dist, 3]), do: [?U, dist]

  def step_2([?U, n | _], {grid, {x, y}}) do
    {Grid.put(grid, {x..x, (y - n)..(y - 1)}, "#"), {x, y - n}}
  end

  def step_2([?D, n | _], {grid, {x, y}}) do
    {Grid.put(grid, {x..x, (y + 1)..(y + n)}, "#"), {x, y + n}}
  end

  def step_2([?L, n | _], {grid, {x, y}}) do
    {Grid.put(grid, {(x - n)..(x - 1), y..y}, "#"), {x - n, y}}
  end

  def step_2([?R, n | _], {grid, {x, y}}) do
    {Grid.put(grid, {(x + 1)..(x + n), y..y}, "#"), {x + n, y}}
  end

  # Apparently many people used the shoelace formula instead of this
  # https://en.wikipedia.org/wiki/Shoelace_formula
  def even_odd_fill_region(grid, xrange) do
    col_regions =
      grid
      |> Grid.regions()
      |> Enum.filter(&match?({{^xrange, _}, _}, &1))

    # BigGrid segments first by column (x) then within each column by row (y),
    # so in order to travel in a straight line we have to come in from the top.
    # It might be better to have a function that chunks the grid up into
    # rectangles instead of exploiting the col-then-row segmentation.
    {_, total_count} =
      Enum.reduce(col_regions, {0, 0}, fn {{xrange, yrange}, cell}, {crossings, count} ->
        y_min..y_max = yrange
        _..x_max = xrange

        filled? = cell == "#"

        # horizontal lines are the easy case
        horizontal? = Range.size(xrange) > 1
        # otherwise we have to consider crossings (to the right in this case,
        # since we're coming from the top)
        cross_start? = Grid.get(grid, {x_max + 1, y_min}) == "#"
        # we can only have two crossings if this region is > 1 tile tall
        cross_end? = y_max > y_min and Grid.get(grid, {x_max + 1, y_max}) == "#"

        inc_count =
          if filled? or Integer.is_odd(crossings) do
            Grid.region_size({xrange, yrange})
          else
            0
          end

        inc_crossing =
          cond do
            !filled? -> 0
            horizontal? -> 1
            cross_start? and cross_end? -> 2
            cross_start? or cross_end? -> 1
            true -> 0
          end

        {crossings + inc_crossing, count + inc_count}
      end)

    total_count
  end
end
