defmodule Util do
  def input_file(year, day, type \\ nil) when is_integer(year) and is_integer(day) do
    ext = if type, do: ".#{type}.txt", else: ".txt"

    Path.join([
      __DIR__,
      "advent_#{year}",
      "day_#{String.pad_leading(Integer.to_string(day), 2, "0")}#{ext}"
    ])
  end

  def read_input!(year, day, type \\ nil) do
    File.read!(input_file(year, day, type))
  end

  def inc(x), do: x + 1
  def dec(x), do: x - 1

  @type point :: {integer, integer}
  @type grid(val) :: %{point => val}
  @type grid() :: grid(any())

  @doc """
  Returns chardata for a pixmap given a grid and a function returning a bool
  value for each grid space.
  """
  @spec pixmap(grid, (grid, point -> boolean)) :: IO.chardata()
  def pixmap(grid, value_fn \\ &default_value_fn/2) do
    {x_min, x_max} = Enum.map(grid, fn {{x, _}, _} -> x end) |> Enum.min_max()
    {y_min, y_max} = Enum.map(grid, fn {{_, y}, _} -> y end) |> Enum.min_max()

    [
      "P1\n",
      Integer.to_string(y_max - y_min + 1),
      " ",
      Integer.to_string(x_max - x_min + 1),
      "\n",
      for x <- x_min..x_max, y <- y_min..y_max do
        if value_fn.(grid, {x, y}), do: "1", else: "0"
      end
    ]
  end

  defp default_value_fn(grid, point), do: !!grid[point]
end
