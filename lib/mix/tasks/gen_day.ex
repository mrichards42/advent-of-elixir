defmodule Mix.Tasks.GenDay do
  use Mix.Task
  require Mix.Generator

  Mix.Generator.embed_template(:module, ~S'''
  defmodule <%= @module %> do
    @moduledoc """
    Day <%= @day %>: TITLE
    """

    def parse_input(input) do
      input
    end

    @doc """
    Part 1: DESCRIPTION

        iex> <%= @module %>.part1(Util.read_input!(<%= @year %>, <%= @day %>))
        nil
    """
    def part1(input) do
      input
      |> parse_input()
    end

    @doc """
    Part 2: DESCRIPTION

        iex> <%= @module %>.part2(Util.read_input!(<%= @year %>, <%= @day %>))
        nil
    """
    def part2(input) do
      input
      |> parse_input()
    end
  end
  ''')

  Mix.Generator.embed_template(:test, ~S'''
  defmodule <%= @module %>Test do
    use ExUnit.Case
    doctest <%= @module %>
  end
  ''')

  @impl Mix.Task
  def run([year_str, day_str]) when is_bitstring(year_str) and is_bitstring(day_str) do
    year = String.to_integer(year_str)
    day = String.to_integer(day_str)
    padded_day = String.pad_leading(Integer.to_string(day), 2, "0")
    file = Path.join(["lib", "advent_#{year}", "day_#{padded_day}.ex"])
    test_file = Path.join(["test", "advent_#{year}", "day_#{padded_day}_test.exs"])
    module = "Advent#{year}.Day#{padded_day}"

    if File.exists?(file) do
      Mix.raise("File for advent #{year} #{padded_day} already exists: #{file}")
    end

    Mix.Generator.create_file(file, module_template(module: module, year: year, day: day))
    Mix.Generator.create_file(test_file, test_template(module: module, year: year, day: day))
  end

  def run([day]) do
    run([Integer.to_string(now().year), day])
  end

  def run([]) do
    run([Integer.to_string(now().day)])
  end

  defp now() do
    # close enough
    DateTime.add(DateTime.utc_now(), -5, :hour)
  end
end
