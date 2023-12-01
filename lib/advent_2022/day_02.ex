defmodule Advent2022.Day02 do
  @moduledoc """
  Day 2: Rock Paper Scissors
  """

  @scores %{
    rock: 1,
    paper: 2,
    scissors: 3,
    win: 6,
    draw: 3,
    lose: 0
  }

  @outcomes [
    %{opponent: :rock, you: :rock, result: :draw},
    %{opponent: :rock, you: :paper, result: :win},
    %{opponent: :rock, you: :scissors, result: :lose},
    %{opponent: :paper, you: :rock, result: :lose},
    %{opponent: :paper, you: :paper, result: :draw},
    %{opponent: :paper, you: :scissors, result: :win},
    %{opponent: :scissors, you: :rock, result: :win},
    %{opponent: :scissors, you: :paper, result: :lose},
    %{opponent: :scissors, you: :scissors, result: :draw}
  ]

  def score_game(outcome) do
    @scores[outcome.you] + @scores[outcome.result]
  end

  def score_partial_game(partial_game) do
    score_game(
      Enum.find(@outcomes, fn outcome ->
        Map.merge(outcome, partial_game) == outcome
      end)
    )
  end

  defmodule Parser do
    import NimbleParsec
    import ParserUtil

    line =
      empty()
      |> ascii_string([?A..?C], 1)
      |> ignore(space())
      |> ascii_string([?X..?Z], 1)
      |> ignore(optional(eol_or_eos()))
      |> wrap()

    defparsec :parser, repeat(line)
  end

  def parse_input(input, mapping) do
    input
    |> ParserUtil.parse!(&Parser.parser/1)
    |> Enum.map(fn [fst, snd] ->
      Map.new(mapping[fst] ++ mapping[snd])
    end)
  end

  @doc """
  Part 1: Lines represent opponent, you

      iex> Advent2022.Day02.part1(Util.read_input!(2022, 2))
      12276
  """
  def part1(input) do
    mapping = %{
      "A" => [opponent: :rock],
      "B" => [opponent: :paper],
      "C" => [opponent: :scissors],
      "X" => [you: :rock],
      "Y" => [you: :paper],
      "Z" => [you: :scissors]
    }

    input
    |> parse_input(mapping)
    |> Enum.map(&score_partial_game/1)
    |> Enum.sum()
  end

  @doc """
  Part 2: Lines represent opponent, result

      iex> Advent2022.Day02.part2(Util.read_input!(2022, 2))
      9975
  """
  def part2(input) do
    mapping = %{
      "A" => [opponent: :rock],
      "B" => [opponent: :paper],
      "C" => [opponent: :scissors],
      "X" => [result: :lose],
      "Y" => [result: :draw],
      "Z" => [result: :win]
    }

    input
    |> parse_input(mapping)
    |> Enum.map(&score_partial_game/1)
    |> Enum.sum()
  end
end
