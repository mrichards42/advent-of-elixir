defmodule Mix.Tasks.GenDay do
  use Mix.Task
  require Mix.Generator

  # Lack of whitespace control/trimming makes the conditionals here this pretty
  # ugly
  Mix.Generator.embed_template(:module, ~S'''
  defmodule <%= @module %> do
    @moduledoc """
    Day <%= @day %>: TITLE
    """

    <%= if @parsec do %>defmodule InputParser do
      import NimbleParsec
      import ParserUtil

      line = ascii_string([?a..?z, ?A..?Z, ?0..?9], min: 1)

      defparser :parse, repeat_1(line |> ignore(eol_or_eos()))
    end<% else %>def parse_input(input) do
      input
    end<% end %>

    @doc """
    Part 1: DESCRIPTION

        iex> <%= @module %>.part1(Util.read_input!(<%= @year %>, <%= @day %>))
        nil
    """
    def part1(input) do
      input
      <%= if @parsec do %>|> InputParser.parse!()<% else %>|> parse_input()<% end %>

      # remove when working on this part
      nil
    end

    @doc """
    Part 2: DESCRIPTION

        iex> <%= @module %>.part2(Util.read_input!(<%= @year %>, <%= @day %>))
        nil
    """
    def part2(input) do
      input
      <%= if @parsec do %>|> InputParser.parse!()<% else %>|> parse_input()<% end %>

      # remove when working on this part
      nil
    end
  end
  ''')

  Mix.Generator.embed_template(:test, ~S'''
  defmodule <%= @module %>Test do
    use ExUnit.Case, async: true
    doctest <%= @module %>
  end
  ''')

  @impl Mix.Task
  def run(argv) do
    run_impl(OptionParser.parse!(argv, strict: [parsec: :boolean, overwrite: :boolean]))
  end

  def run_impl({opts, [year_str, day_str]}) do
    year = String.to_integer(year_str)
    day = String.to_integer(day_str)
    padded_day = String.pad_leading(Integer.to_string(day), 2, "0")
    file = Path.join(["lib", "advent_#{year}", "day_#{padded_day}.ex"])
    test_file = Path.join(["test", "advent_#{year}", "day_#{padded_day}_test.exs"])
    module = "Advent#{year}.Day#{padded_day}"

    if File.exists?(file) and !opts[:overwrite] do
      Mix.raise("File for advent #{year} #{padded_day} already exists: #{file}")
    end

    template_args = [module: module, year: year, day: day] ++ opts ++ [parsec: false]
    Mix.Generator.create_file(file, module_template(template_args))
    Mix.Generator.create_file(test_file, test_template(template_args))
  end

  def run_impl({opts, [day_str]}) do
    run_impl({opts, [Integer.to_string(now().year), day_str]})
  end

  def run_impl({opts, []}) do
    run_impl({opts, [Integer.to_string(now().day)]})
  end

  defp now() do
    # close enough
    DateTime.add(DateTime.utc_now(), -5, :hour)
  end
end
