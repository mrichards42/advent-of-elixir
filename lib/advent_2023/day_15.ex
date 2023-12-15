defmodule Advent2023.Day15 do
  @moduledoc """
  Day 15: Lens Library
  """

  def parse_input(input) do
    input |> String.trim() |> String.split(",")
  end

  @doc """
  Part 1: Hash all the inputs

      iex> Advent2023.Day15.part1(Util.read_input!(2023, 15))
      517015
  """
  def part1(input) do
    input
    |> parse_input()
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  def hash(str), do: hash(0, String.to_charlist(str))
  def hash(val, [n | rest]), do: hash(rem((val + n) * 17, 256), rest)
  def hash(val, []), do: val

  @doc """
  Part 2: Move lenses into boxes and then score them

      iex> Advent2023.Day15.part2(Util.read_input!(2023, 15))
      286104
  """
  def part2(input) do
    empty_boxes = Map.new(Enum.map(0..255, fn idx -> {idx, []} end))

    input
    |> parse_input()
    |> Enum.reduce(empty_boxes, &step/2)
    |> Enum.flat_map(fn {box, lenses} ->
      Enum.with_index(Enum.reverse(lenses), fn {_, focal_length}, slot ->
        (box + 1) * (slot + 1) * focal_length
      end)
    end)
    |> Enum.sum()
  end

  def step(instruction, boxes) do
    if String.ends_with?(instruction, "-") do
      # delete instruction
      label = String.slice(instruction, 0..-2)
      box = hash(label)

      Map.update!(boxes, box, &remove_lens(&1, label))
    else
      # add or replace instruction
      [label, focal_length_str] = String.split(instruction, "=")
      focal_length = String.to_integer(focal_length_str)
      box = hash(label)

      Map.update!(boxes, box, fn lenses ->
        if has_lens?(lenses, label) do
          replace_lens(lenses, label, focal_length)
        else
          add_lens(lenses, label, focal_length)
        end
      end)
    end
  end

  def remove_lens(lenses, label) do
    Enum.reject(lenses, &match?({^label, _}, &1))
  end

  def has_lens?(lenses, label) do
    Enum.find(lenses, false, &match?({^label, _}, &1))
  end

  def replace_lens(lenses, label, focal_length) do
    Enum.map(lenses, fn
      {^label, _} -> {label, focal_length}
      other -> other
    end)
  end

  def add_lens(lenses, label, focal_length) do
    [{label, focal_length} | lenses]
  end
end
