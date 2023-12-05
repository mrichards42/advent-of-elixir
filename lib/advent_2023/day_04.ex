defmodule Advent2023.Day04 do
  @moduledoc """
  Day 4: Scratchcards
  """

  defmodule InputParser do
    import NimbleParsec
    import ParserUtil

    number_list =
      repeat_1(
        ignore(ascii_string([?\s], min: 0))
        |> integer(min: 1)
      )

    card =
      empty()
      |> ignore(string("Card"))
      |> ignore(ascii_string([?\s], min: 1))
      |> unwrap_and_tag(integer(min: 1), :card_number)
      |> ignore(string(": "))
      |> tag(number_list, :winning)
      |> ignore(string(" | "))
      |> tag(number_list, :yours)
      |> reduce({Map, :new, []})

    defparser :parse, repeat_1(card |> ignore(eol_or_eos()))
  end

  @doc """
  Part 1: Sum of card scores with first set of rules

      iex> Advent2023.Day04.part1(Util.read_input!(2023, 4))
      25651
  """
  def part1(input) do
    input
    |> InputParser.parse!()
    |> Enum.map(&card_score_1/1)
    |> Enum.sum()
  end

  def matching_numbers(%{winning: winning, yours: yours}) do
    Enum.count(yours, &Enum.member?(winning, &1))
  end

  def card_score_1(card) do
    case matching_numbers(card) do
      0 -> 0
      n -> 2 ** (n - 1)
    end
  end

  @doc """
  Part 2: Total number of cards after following rules 2

      iex> Advent2023.Day04.part2(Util.read_input!(2023, 4))
      19499881
  """
  def part2(input) do
    cards = InputParser.parse!(input)

    # Each card duplicates the next n cards where n is the number of matches on
    # this card. Rather than keep track of cards individually, we keep track of
    # the number of copies of each card.
    init_copies = Enum.into(cards, %{}, fn card -> {card.card_number, 1} end)

    final_copies =
      Enum.reduce(cards, init_copies, fn card, card_copies ->
        matching_count = matching_numbers(card)
        copies_of_this_card = card_copies[card.card_number]

        Range.shift(1..matching_count//1, card.card_number)
        |> Enum.into(%{}, fn other_card_num -> {other_card_num, copies_of_this_card} end)
        |> Map.merge(card_copies, fn _k, v1, v2 -> v1 + v2 end)
      end)

    final_copies
    |> Map.values()
    |> Enum.sum()
  end
end
