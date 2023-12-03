defmodule Advent2023.Day03 do
  @moduledoc """
  Day 3: Gear Ratios
  """

  defmodule InputParser do
    import NimbleParsec
    import ParserUtil

    cell =
      choice([
        ignore(repeat_1(string("."))),
        repeat_1(byte_offset(ascii_char([?0..?9]))) |> wrap(),
        byte_offset(ascii_char([1..127])) |> wrap()
      ])

    defparser :parse_line, repeat(cell) |> eos()

    def as_cell(chars_with_offset, line) do
      str = List.to_string(Enum.map(chars_with_offset, &elem(&1, 0)))
      points = Enum.map(chars_with_offset, fn {_, offset} -> {offset, line} end)

      case Integer.parse(str) do
        {num, ""} -> %{value: num, points: points}
        _ -> %{value: str, points: points}
      end
    end

    @doc """
    Parses input into a `grid` -- a Map with {x, y} keys, and values
    representing each cell as another Map %{value: ..., points: ...}

    Note that grid values are _not_ unique, since a cell can span multiple
    points in the grid.
    """
    def parse!(input) do
      for {line, line_idx} <- Enum.with_index(String.split(input, "\n")),
          chars_with_offset <- parse_line!(line),
          cell <- [as_cell(chars_with_offset, line_idx)],
          point <- cell.points,
          into: %{} do
        {point, cell}
      end
    end
  end

  def point_neighbors({x, y}) do
    [
      # left
      {x - 1, y - 1},
      {x - 1, y},
      {x - 1, y + 1},
      # middle
      {x, y - 1},
      {x, y + 1},
      # right
      {x + 1, y - 1},
      {x + 1, y},
      {x + 1, y + 1}
    ]
  end

  def neighbors(grid, cell) do
    for point <- cell.points,
        neighbor <- point_neighbors(point),
        not Enum.member?(cell.points, neighbor),
        neighbor_cell <- [Map.get(grid, neighbor)],
        neighbor_cell != nil,
        uniq: true do
      neighbor_cell
    end
  end

  def number_cell?(cell), do: is_number(cell.value)
  def symbol_cell?(cell), do: is_binary(cell.value)

  def part_number?(grid, cell) do
    number_cell?(cell) and Enum.any?(neighbors(grid, cell), &symbol_cell?/1)
  end

  def gear?(grid, cell) do
    cell.value == "*" and Enum.count(neighbors(grid, cell), &number_cell?/1) == 2
  end

  def gear_ratio(grid, cell) do
    [a, b] = neighbors(grid, cell)
    a.value * b.value
  end

  @doc """
  Part 1: Sum of all part numbers

      iex> Advent2023.Day03.part1(Util.read_input!(2023, 3))
      550934
  """
  def part1(input) do
    grid = InputParser.parse!(input)

    cells = Enum.uniq(Map.values(grid))

    cells
    |> Enum.filter(&part_number?(grid, &1))
    |> Enum.map(& &1.value)
    |> Enum.sum()
  end

  @doc """
  Part 2: Sum of all gear ratios

      iex> Advent2023.Day03.part2(Util.read_input!(2023, 3))
      81997870
  """
  def part2(input) do
    grid = InputParser.parse!(input)

    cells = Enum.uniq(Map.values(grid))

    cells
    |> Enum.filter(&gear?(grid, &1))
    |> Enum.map(&gear_ratio(grid, &1))
    |> Enum.sum()
  end
end
