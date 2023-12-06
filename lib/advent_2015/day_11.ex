defmodule Advent2015.Day11 do
  @moduledoc """
  Day 11: Corporate Policy
  """

  @doc """
  Part 1: Next valid password

      iex> Advent2015.Day11.part1(Util.read_input!(2015, 11))
      "hepxxyzz"
  """
  def part1(input) do
    input
    |> String.trim()
    |> string_to_password()
    |> find_next_password()
    |> password_to_string()
  end

  @doc """
  Part 2: Next next password

      iex> Advent2015.Day11.part2(Util.read_input!(2015, 11))
      "heqaabcc"
  """
  def part2(input) do
    input
    |> String.trim()
    |> string_to_password()
    |> find_next_password()
    |> find_next_password()
    |> password_to_string()
  end

  # Passwords are reversed so we can operate on them efficiently as lists

  def string_to_password(str) do
    str |> String.to_charlist() |> Enum.reverse()
  end

  def password_to_string(str) do
    str |> Enum.reverse() |> to_string()
  end

  def find_next_password(password) do
    password
    |> inc_password()
    |> Stream.unfold(fn x -> {x, inc_password(x)} end)
    |> Stream.drop_while(fn pass -> !valid_password?(pass) end)
    |> Enum.at(0)
  end

  def inc_password([?z | rest]), do: [?a | inc_password(rest)]

  for letter <- ?a..?y do
    def inc_password([unquote(letter) | rest]), do: [unquote(letter + 1) | rest]
  end

  ## Password checkers

  def valid_password?(password) do
    has_straight?(password) and no_bad_letters?(password) and has_two_pairs?(password)
  end

  def has_straight?([c, b, a | _] = password) do
    (c == b + 1 and b == a + 1) or has_straight?(tl(password))
  end

  def has_straight?(_), do: false

  def no_bad_letters?(password) do
    !Enum.any?([?i, ?o, ?l], &Enum.member?(password, &1))
  end

  def has_one_pair?([b, a | _] = password) do
    a == b or has_one_pair?(tl(password))
  end

  def has_one_pair?(_), do: false

  def has_two_pairs?([b, a | rest] = password) do
    cond do
      a == b -> has_one_pair?(rest)
      true -> has_two_pairs?(tl(password))
    end
  end

  def has_two_pairs?(_), do: false
end
