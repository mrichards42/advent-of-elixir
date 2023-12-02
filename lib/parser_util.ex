defmodule ParserUtil do
  @moduledoc """
  Missing NimbleParsec functions
  """

  import NimbleParsec

  def space do
    string(" ")
  end

  def eol do
    string("\n")
  end

  def eol_or_eos do
    choice([eol(), eos()])
  end

  def many(comb, options \\ []) do
    times(comb, options ++ [min: 0])
  end

  def many_1(comb, options \\ []) do
    many(comb, options ++ [min: 1])
  end

  def sep_by(comb, sep, options \\ [])

  def sep_by(comb, sep, options) when is_list(options) do
    if Keyword.get(options, :min, 0) == 0 do
      optional(sep_by(comb, sep, [min: 1] ++ options))
    else
      comb
      |> times(
        ignore(sep) |> concat(comb),
        Keyword.update!(options, :min, &(&1 - 1))
      )
    end
  end

  def sep_by(comb, sep, count) when is_integer(count) do
    comb |> times(ignore(sep) |> concat(comb), count - 1)
  end

  def sep_by_1(comb, sep, options \\ []) do
    sep_by(comb, sep, options ++ [min: 1])
  end

  def extract_result!(result_tuple) do
    case result_tuple do
      {:ok, result, "", _, _, _} ->
        result

      {:ok, _, rest, _, _, _} ->
        raise "Parser failed to consume the entire input; remaining: #{inspect(rest)}"

      {:error, err, rest, _, {line, char}, _} ->
        raise "Parsing failure: at line #{line} char #{char}: #{err}. Rest: #{inspect(rest)}"
    end
  end

  def parse!(input, parser) do
    extract_result!(parser.(input))
  end

  @doc """
  Like defparsec, but also defines a function `name!` that returns the parse
  result or raises an error.
  """
  defmacro defparser(name, parser) do
    name_bang = String.to_atom(Atom.to_string(name) <> "!")

    quote do
      defparsec unquote(name), unquote(parser)

      @doc """
      Parses the given binary. Returns a list of parse results, or raises an
      error if the input did not fully match.
      """
      @spec unquote(name_bang)(binary) :: [term]
      def unquote(name_bang)(input) do
        extract_result!(unquote(name)(input))
      end
    end
  end
end
