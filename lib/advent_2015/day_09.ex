defmodule Advent2015.Day09 do
  @moduledoc """
  Day 9: All in a Single Night
  """

  defmodule InputParser do
    import NimbleParsec
    import ParserUtil

    place = ascii_string([?a..?z, ?A..?Z], min: 1)

    line =
      empty()
      |> concat(place)
      |> ignore(string(" to "))
      |> concat(place)
      |> ignore(string(" = "))
      |> integer(min: 1)
      |> wrap()

    defparser :parse_raw, repeat_1(line |> ignore(eol_or_eos()))

    def parse!(input) do
      input
      |> parse_raw!()
      # don't forget about reverse paths! this is an undirected graph
      |> Enum.flat_map(fn [a, b, dist] -> [[a, b, dist], [b, a, dist]] end)
    end
  end

  def all_paths(graph) do
    starts =
      graph
      |> Enum.map(&{[List.first(&1)], 0})
      |> Enum.uniq()

    all_paths(starts, graph, length(starts) - 1)
  end

  def all_paths(paths, _, 0) do
    paths
  end

  def all_paths(paths, graph, n) do
    # this graph is small enough that we can just enumerate every path
    result =
      Enum.flat_map(paths, fn {[current | _] = path, total_dist} ->
        for [^current, neighbor, dist] <- graph,
            !Enum.member?(path, neighbor),
            do: {[neighbor | path], total_dist + dist}
      end)

    all_paths(result, graph, n - 1)
  end

  @doc """
  Part 1: Shortest path between any two points

      iex> Advent2015.Day09.part1(Util.read_input!(2015, 9))
      141
  """
  def part1(input) do
    input
    |> InputParser.parse!()
    |> all_paths()
    |> Enum.min_by(&elem(&1, 1))
    |> elem(1)
  end

  @doc """
  Part 2: Longest path between any two points

      iex> Advent2015.Day09.part2(Util.read_input!(2015, 9))
      736
  """
  def part2(input) do
    input
    |> InputParser.parse!()
    |> all_paths()
    |> Enum.max_by(&elem(&1, 1))
    |> elem(1)
  end
end
