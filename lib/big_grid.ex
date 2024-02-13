run_assertions = false

defmodule BigGrid do
  @moduledoc """
  BigGrids are optimized for very large and/or sparse grids where enumerating
  every single point on the grid would be prohibitive.

  You should alias one of the submodules (BigGrid1D, BigGrid2D, BigGrid3D)

  BigGrids compact space into non-overlapping regions that all have the same
  value. Regions are compacted separately per axis -- in a 2d grid, the x axis
  is broken up into sections; each x-section contains a y axis that is itself
  broken into separate sections.

  For example, given a 2d grid including the following boxes:

      +-----+------------+
      |     |    +---+   |
      |  A  |    |   |   |
      |     |    | B |   |
      +-----+    |   |   |
      |          +---+   |
      |                  |
      |                  |
      |        +---+     |
      |        | C |     |
      +--------+---+-----+

  The x-axis would be segmented as follows, and then each region would be
  segmented separately along the y-axis, for a total of 12 regions (B and C
  boxes got split into 2 regions each)

      +-----+--+-+-+-+---+           +-----+--+-+-+-+---+
      |     |  | | | |   |           |     |  | +-+-+   |
      |     |  | | | |   |           |  A  |  | | | |   |
      |     |  | | | |   |           |     |  | |B|B|   |
      |     |  | | | |   |           +-----+  | | | |   |
      |     |  | | | |   |           |     |  | +-+-+   |
      |     |  | | | |   |           |     |  | | | |   |
      |     |  | | | |   |           |     |  | | | |   |
      |     |  | | | |   |           |     |  +-+-+ |   |
      |     |  | | | |   |           |     |  |C|C| |   |
      +-----+--+-+-+-+---+           +-----+--+-+-+-+---+

  If instead we have naively divided the axes into sections across the entire
  grid we would have ended up with significantly more regions (5x6 = 30)

      +-----+--+-+-+-+---+
      +--A--+--+-+-+-+---+
      |  A  |  | |B|B|   |
      |  A  |  | |B|B|   |
      +-----+--+-+B+B+---+
      +-----+--+-+-+-+---+
      |     |  | | | |   |
      |     |  | | | |   |
      +-----+--+-+-+-+---+
      |     |  |C|C| |   |
      +-----+--+-+-+-+---+
  """

  defmodule BigGrid1D do
    @moduledoc """
    1D BigGrid representing a line.

    User code is unlikely to need this module, but it serves as the base for
    all higher dimension BigGrids since this is where the splitting logic
    lives.
    """

    @typep region :: {Range.t(), value}
    @type t :: [region]
    @type point1d :: integer
    @type point1d_range :: Range.t() | integer
    @type value :: any

    @spec new() :: t
    @spec new(t) :: t
    def new(regions \\ []), do: Enum.sort(regions)

    @doc """
    Returns the underlying regions that make up the grid.
    """
    @spec regions(t) :: [{Range.t(), value}]
    def regions(line) do
      line
    end

    @doc """
    Returns the length of a region.
    """
    @spec region_size(Range.t()) :: integer
    def region_size(x_range) do
      Range.size(x_range)
    end

    @doc """
    Gets the value at `idx`, or `default` if it does not exist.
    """
    @spec get(t, point1d, value) :: value
    def get(line, idx, default \\ nil) do
      case Enum.find(line, fn {first..last, _} -> first <= idx and idx <= last end) do
        {_, value} -> value
        _ -> default
      end
    end

    @doc """
    Sets the value at `k` (a point or range).
    """
    @spec put(t, point1d_range, value) :: t
    def put(line, point_or_range, val),
      do: update(line, point_or_range, val, fn _ -> val end)

    @doc """
    Updates the value at `k` (an index or range) using `fun`. If `k` does not
    exist, calls `fun.(default)`.

    If `k` is a range, updates all values in the range, splitting existing
    regions apart if necessary. In this case, `fun` may be called more than
    once if there are multiple overlapping regions.
    """
    @spec update(t, Range.t(), value, (value -> value)) :: t
    def update(line, %Range{} = k, default, fun) when is_function(fun, 1) do
      {new_line, rest_k} =
        Enum.flat_map_reduce(line, k, fn
          # we've consumed the entire key, nothing left to do
          region, nil ->
            {[region], nil}

          region, k1..k2 = k ->
            {r1..r2 = r, val} = region
            # split off part of the current region
            split = fn new_range -> {new_range, val} end
            # update part of the current region
            update = fn new_range -> {new_range, fun.(val)} end
            # create a new region
            new = fn new_range -> {new_range, default} end

            # Allen's intervals
            # https://link.springer.com/referenceworkentry/10.1007/978-0-387-39940-9_1515/tables/1
            cond do
              # r before k: skip, we'll get to k later
              r2 < k1 ->
                {[region], k}

              # r after k: process k, then we're done since the grid should be
              # in order
              r1 > k2 ->
                {[new.(k), region], nil}

              r1 < k1 ->
                cond do
                  # r contains k
                  # RRRRRRRRR
                  #    KKKK
                  r2 > k2 -> {[split.(r1..(k1 - 1)), update.(k), split.((k2 + 1)..r2)], nil}
                  # r finished by k
                  # RRRRRRRRR
                  #    KKKKKK
                  r2 == k2 -> {[split.(r1..(k1 - 1)), update.(k)], nil}
                  # r overlaps k
                  # RRRRRR
                  #    KKKKKK
                  # inclusive ranges means this is >= instead of just >
                  r2 >= k1 -> {[split.(r1..(k1 - 1)), update.(k1..r2)], (r2 + 1)..k2}
                end

              r1 > k1 ->
                cond do
                  # r contained by k
                  #    RRRR
                  # KKKKKKKKK
                  r2 < k2 -> {[new.(k1..(r1 - 1)), update.(r)], (r2 + 1)..k2}
                  # r finishes k
                  #     RRRRR
                  # KKKKKKKKK
                  r2 == k2 -> {[new.(k1..(r1 - 1)), update.(r)], nil}
                  # r overlapped by k
                  #    RRRRRR
                  # KKKKKK
                  # inclusive ranges means this is <= instead of just <
                  r1 <= k2 -> {[new.(k1..(r1 - 1)), update.(r1..k2), split.((k2 + 1)..r2)], nil}
                end

              # here we already have r1 == k1
              r1 == k1 ->
                cond do
                  # r starts k
                  # RRRRR
                  # KKKKKKKKK
                  r2 < k2 -> {[update.(r)], (r2 + 1)..k2}
                  # r started by k
                  # RRRRRRRRR
                  # KKKKK
                  r2 > k2 -> {[update.(k), split.((k2 + 1)..r2)], nil}
                  # otherwise this is "equals"
                  true -> {[update.(k)], nil}
                end
            end
        end)

      if rest_k == nil do
        new_line
      else
        # TODO: inefficient, flat_map_reduce doesn't handle this case, consider
        # creating our own version?
        new_line ++ [{rest_k, default}]
      end
      |> check_invariants!([:update, line, k, default, fun])
    end

    @spec update(t, point1d, value, (value -> value)) :: t
    def update(line, idx, default, val) when is_integer(idx) do
      update(line, idx..idx, default, val)
    end

    if run_assertions do
      IO.puts("RUNNING ASSERTIONS")

      defp check_invariants!([fst | rest] = grid, op) do
        Enum.reduce(rest, fst, fn {this, _}, {prev, _} = x ->
          if prev.last < this.first do
            x
          else
            raise "Oops! out of order after #{inspect(op)}: " <>
                    "#{inspect(prev)} should be before #{inspect(this)}"
          end
        end)

        grid
      end
    else
      defp check_invariants!(grid, _), do: grid
    end
  end

  defmodule BigGrid2D do
    @moduledoc """
    2D BigGrid. See the `BigGrid` module doc for a full explanation.
    """
    @typep grid1d :: {Range.t(), BigGrid1D.t()}
    @type t :: [grid1d]
    @type point2d :: {integer, integer}
    @type point2d_range :: {Range.t() | integer, Range.t() | integer}
    @type value :: any

    @spec new(t) :: t
    def new(grid1d_list \\ []), do: Enum.sort(grid1d_list)

    @doc """
    Returns the underlying regions that make up the grid.
    """
    @spec regions(t) :: [{{Range.t(), Range.t()}, value}]
    def regions(grid) do
      for {xrange, ydim} <- grid, {yrange, val} <- ydim, do: {{xrange, yrange}, val}
    end

    @doc """
    Returns the area of a region.
    """
    @spec region_size({Range.t(), Range.t()}) :: integer
    def region_size({x_range, y_range}) do
      Range.size(x_range) * Range.size(y_range)
    end

    @spec get(t, point2d) :: value
    @spec get(t, point2d, value) :: value
    def get(grid, {x, y}, default \\ nil) do
      case BigGrid1D.get(grid, x, default) do
        ^default -> default
        ydim -> BigGrid1D.get(ydim, y, default)
      end
    end

    @spec put(t, point2d_range, value) :: t
    def put(line, point_or_range, val), do: update(line, point_or_range, val, fn _ -> val end)

    @spec update(t, point2d_range, value, (value -> value)) :: t
    def update(grid, {xk, yk}, default, fun) when is_function(fun, 1) do
      BigGrid1D.update(grid, xk, BigGrid1D.new([{yk, default}]), fn ydim ->
        BigGrid1D.update(ydim, yk, default, fun)
      end)
    end
  end

  defmodule BigGrid3D do
    @moduledoc """
    3D BigGrid. See the `BigGrid` module doc for a full explanation.
    """
    @typep grid2d :: {Range.t(), BigGrid.t()}
    @type t :: [grid2d]
    @type point3d :: {integer, integer, integer}
    @type point3d_range :: {Range.t() | integer, Range.t() | integer, Range.t() | integer}
    @type value :: any

    @spec new(t) :: t
    def new(grid2d_list \\ []), do: Enum.sort(grid2d_list)

    @doc """
    Returns the underlying regions that make up the grid.
    """
    @spec regions(t) :: [{{Range.t(), Range.t(), Range.t()}, value}]
    def regions(grid) do
      for {x, ydim} <- grid,
          {y, zdim} <- ydim,
          {z, val} <- zdim,
          do: {{x, y, z}, val}
    end

    @doc """
    Returns the volume of a region.
    """
    @spec region_size({Range.t(), Range.t(), Range.t()}) :: integer
    def region_size({x_range, y_range, z_range}) do
      Range.size(x_range) * Range.size(y_range) * Range.size(z_range)
    end

    @spec get(t, point3d) :: value
    @spec get(t, point3d, value) :: value
    def get(grid, {x, y, z}, default \\ nil) do
      case BigGrid2D.get(grid, {x, y}, default) do
        ^default -> default
        zdim -> BigGrid1D.get(zdim, z, default)
      end
    end

    @spec put(t, point3d_range, value) :: t
    def put(line, point_or_range, val), do: update(line, point_or_range, val, fn _ -> val end)

    @spec update(t, point3d_range, value, (value -> value)) :: t
    def update(grid, {xk, yk, zk}, default, fun) when is_function(fun, 1) do
      BigGrid2D.update(grid, {xk, yk}, BigGrid2D.new([{zk, default}]), fn zdim ->
        BigGrid1D.update(zdim, zk, default, fun)
      end)
    end
  end
end
