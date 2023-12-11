defmodule Advent2023.Day07 do
  @moduledoc """
  Day 7: Camel Cards
  """

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x ->
      [hand, bid] = String.split(x, " ")
      {String.to_charlist(hand), String.to_integer(bid)}
    end)
  end

  @doc """
  Part 1: Rank hands and multiply rank by "bid"

      iex> Advent2023.Day07.part1(Util.read_input!(2023, 7))
      250254244
  """
  def part1(input) do
    input
    |> parse_input()
    |> Enum.sort_by(fn {cards, _} -> hand_rank_full_1(cards) end, :desc)
    |> Enum.with_index(1)
    |> Enum.map(fn {{_, bid}, rank} -> bid * rank end)
    |> Enum.sum()
  end

  @card_vals Map.new(Enum.with_index([?A, ?K, ?Q, ?J, ?T, ?9, ?8, ?7, ?6, ?5, ?4, ?3, ?2, ?X]))
  def card_rank(card), do: @card_vals[card]

  def hand_rank(cards) do
    freqs = cards |> Enum.frequencies() |> Map.values() |> Enum.sort()

    case freqs do
      [5] -> 1
      [1, 4] -> 2
      [2, 3] -> 3
      [1, 1, 3] -> 4
      [1, 2, 2] -> 5
      [1, 1, 1, 2] -> 6
      [1, 1, 1, 1, 1] -> 7
    end
  end

  def hand_rank_full_1(cards) do
    [hand_rank(cards) | Enum.map(cards, &card_rank/1)]
  end

  @doc """
  Part 2: Same thing, but Jacks are Jokers, and are wild

      iex> Advent2023.Day07.part2(Util.read_input!(2023, 7))
      250087440
  """
  def part2(input) do
    input
    |> parse_input()
    |> Enum.map(fn {cards, bid} -> {replace_jacks_with_jokers(cards), bid} end)
    |> Enum.sort_by(fn {cards, _} -> hand_rank_full_2(cards) end, :desc)
    |> Enum.with_index(1)
    |> Enum.map(fn {{_, bid}, rank} -> bid * rank end)
    |> Enum.sum()
  end

  def replace_jacks_with_jokers(cards) do
    Enum.map(cards, fn
      ?J -> ?X
      other -> other
    end)
  end

  def hand_rank_2(cards) do
    cards
    |> possible_cards()
    |> Enum.map(&hand_rank/1)
    |> Enum.min()
  end

  def hand_rank_full_2(cards) do
    [hand_rank_2(cards) | Enum.map(cards, &card_rank/1)]
  end

  def possible_cards([]) do
    [[]]
  end

  def possible_cards([card | rest]) do
    if card == ?X do
      for replacement <- Map.keys(@card_vals), r <- possible_cards(rest) do
        [replacement | r]
      end
    else
      for fst <- [card], r <- possible_cards(rest) do
        [fst | r]
      end
    end
  end
end
