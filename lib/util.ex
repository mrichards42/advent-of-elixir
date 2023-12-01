defmodule Util do
  def input_file(year, day, type \\ nil) when is_integer(year) and is_integer(day) do
    ext = if type, do: ".#{type}.txt", else: ".txt"
    Path.join([
      __DIR__,
      "advent_#{year}",
      "day_#{String.pad_leading(Integer.to_string(day), 2, "0")}#{ext}"
    ])
  end

  def read_input!(year, day, type \\ nil) do
    File.read!(input_file(year, day, type))
  end
end
