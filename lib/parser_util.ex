defmodule ParserUtil do
  @moduledoc """
  Missing NimbleParsec functions
  """

  import NimbleParsec
  @type t :: NimbleParsec.t()
  @type min_and_max :: NimbleParsec.min_and_max()

  ## -- Combinators -----------------------------------------------------------

  def space(prev \\ empty()) do
    prev |> string(" ")
  end

  def eol(prev \\ empty()) do
    prev |> string("\n")
  end

  def eol_or_eos(prev \\ empty()) do
    prev |> choice([eol(), eos()])
  end

  @doc """
  Parses `to_repeat` one or more times.
  """
  @spec repeat_1(t) :: t
  @spec repeat_1(t, t) :: t
  def repeat_1(prev \\ empty(), to_repeat) do
    times(prev, to_repeat, min: 1)
  end

  @doc """
  Parses `subj` separated by `sep`.

  Takes the same options as `NimbleParsec.times/3`, either an exact count or a
  min and max.
  """
  @spec sep_by(t, t, pos_integer | [min_and_max]) :: t
  @spec sep_by(t, t, t, pos_integer | [min_and_max]) :: t
  def sep_by(prev \\ empty(), subj, sep, count_or_min_max)

  def sep_by(prev, subj, _sep, count) when is_integer(count) and count == 1 do
    prev |> concat(subj)
  end

  def sep_by(prev, subj, sep, count) when is_integer(count) and count > 1 do
    prev |> concat(subj) |> times(ignore(sep) |> concat(subj), count - 1)
  end

  def sep_by(prev, subj, sep, min_max) when is_list(min_max) do
    if Keyword.get(min_max, :min, 0) == 0 do
      optional(sep_by(prev, subj, sep, [min: 1] ++ min_max))
    else
      prev
      |> concat(subj)
      |> times(ignore(sep) |> concat(subj), dec_min_max(min_max))
    end
  end

  defp dec_min_max(min_max) when is_list(min_max) do
    Enum.map(min_max, fn
      {k, v} when k == :min or k == :max -> {k, v - 1}
      other -> other
    end)
  end

  @doc """
  Parses 0 or more occurrences of `subj` separated by `sep`.
  """
  @spec sep_by_0(t, t) :: t
  @spec sep_by_0(t, t, t) :: t
  def sep_by_0(prev \\ empty(), subj, sep), do: sep_by(prev, subj, sep, min: 0)

  @doc """
  Parses 1 or more occurrences of `subj` separated by `sep`.
  """
  @spec sep_by_0(t, t) :: t
  @spec sep_by_0(t, t, t) :: t
  def sep_by_1(prev \\ empty(), subj, sep), do: sep_by(prev, subj, sep, min: 1)

  ## -- Parsing helpers -------------------------------------------------------

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
