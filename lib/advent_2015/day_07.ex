defmodule Advent2015.Day07 do
  @moduledoc """
  Day 7: Some Assembly Required
  """

  import Bitwise, only: [bnot: 1, band: 2, bor: 2, bsl: 2, bsr: 2]

  defmodule InputParser do
    import NimbleParsec
    import ParserUtil

    wire = ascii_string([?a..?z], min: 1)
    input = choice([wire, integer(min: 1)])
    assign = ignore(string(" -> ")) |> concat(wire)

    p_unary =
      empty()
      |> replace(string("NOT "), :not)
      |> concat(input)
      |> concat(assign)

    p_binary =
      empty()
      |> concat(input)
      |> choice([
        replace(string(" AND "), :and),
        replace(string(" OR "), :or),
        replace(string(" LSHIFT "), :lshift),
        replace(string(" RSHIFT "), :rshift)
      ])
      |> concat(input)
      |> concat(assign)

    p_assign =
      replace(empty(), :assign)
      |> concat(input)
      |> concat(assign)

    stmt = choice([p_assign, p_unary, p_binary]) |> wrap()

    defparser :parse, repeat_1(stmt |> ignore(eol_or_eos()))
  end

  @doc """
  Part 1: Run through the instructions

      iex> Advent2015.Day07.part1(Util.read_input!(2015, 7))
      3176
  """
  def part1(input) do
    input
    |> InputParser.parse!()
    |> run_all()
    |> Map.get("a")
  end

  def load!(_env, val) when is_integer(val), do: val
  def load!(env, val), do: Map.fetch!(env, val)

  def interpret!(env, [:assign, x, _out]), do: load!(env, x)
  def interpret!(env, [:not, x, _out]), do: bnot(load!(env, x))
  def interpret!(env, [x, :and, y, _out]), do: band(load!(env, x), load!(env, y))
  def interpret!(env, [x, :or, y, _out]), do: bor(load!(env, x), load!(env, y))
  def interpret!(env, [x, :lshift, y, _out]), do: bsl(load!(env, x), load!(env, y))
  def interpret!(env, [x, :rshift, y, _out]), do: bsr(load!(env, x), load!(env, y))

  def run_all(env \\ %{}, instructions) do
    # Rather than make this a graph and do a topological sort, we can just run
    # through the instructions a bunch of times while ignoring errors, until
    # we've successfully processed all the instructions
    {result, bad_instructions} =
      Enum.reduce(instructions, {env, []}, fn instruction, {env, bad_instructions} ->
        try do
          out = List.last(instruction)
          val = interpret!(env, instruction)
          {Map.put(env, out, val), bad_instructions}
        rescue
          # instructions end up reversed, but order doesn't matter
          KeyError -> {env, [instruction | bad_instructions]}
        end
      end)

    case bad_instructions do
      [] -> result
      more when length(more) < length(instructions) -> run_all(result, more)
      oops -> raise "Unable to process all instructions! remainder: #{inspect(oops)}"
    end
  end

  @doc """
  Part 2: Run through the instructions twice, replacing input to `b`

      iex> Advent2015.Day07.part2(Util.read_input!(2015, 7))
      14710
  """
  def part2(input) do
    instructions = InputParser.parse!(input)
    final_a = Map.get(run_all(instructions), "a")

    instructions_2 =
      Enum.map(instructions, fn
        [:assign, _, "b"] -> [:assign, final_a, "b"]
        instruction -> instruction
      end)

    instructions_2
    |> run_all()
    |> Map.get("a")
  end
end
