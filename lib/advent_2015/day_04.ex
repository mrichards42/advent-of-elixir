defmodule Advent2015.Day04 do
  @moduledoc """
  Day 4: The Ideal Stocking Stuffer
  """

  def md5_hex(key) do
    Base.encode16(:crypto.hash(:md5, key))
  end

  # Chunking with Task.async_stream (and doing filtering in the async task) got
  # this down to 3-4 seconds on my machine, where the single-threaded version
  # was more like 10-15 seconds

  def find_hash(key_prefix, hash_prefix) do
    Stream.iterate(0, &Util.inc/1)
    |> Stream.chunk_every(5000)
    |> Task.async_stream(fn xs ->
      Enum.find(xs, fn x ->
        "#{key_prefix}#{x}" |> md5_hex() |> String.starts_with?(hash_prefix)
      end)
    end)
    |> Enum.find_value(fn {:ok, x} -> x end)
  end

  @doc """
  Part 1: First hash starting with five 0s

      iex> Advent2015.Day04.part1(Util.read_input!(2015, 4))
      282749
  """
  def part1(input) do
    key_prefix = String.trim(input)
    find_hash(key_prefix, "00000")
  end

  @doc """
  Part 2: First hash starting with six 0s

      iex> Advent2015.Day04.part2(Util.read_input!(2015, 4))
      9962624
  """
  def part2(input) do
    key_prefix = String.trim(input)
    find_hash(key_prefix, "000000")
  end
end
