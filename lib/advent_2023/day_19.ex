defmodule Advent2023.Day19 do
  @moduledoc """
  Day 19: Aplenty
  """

  defmodule InputParser do
    import NimbleParsec
    import ParserUtil

    label = ascii_string([?a..?z, ?A, ?R], min: 1)

    rule =
      empty()
      |> unwrap_and_tag(ascii_char([?x, ?m, ?a, ?s]), :prop)
      |> unwrap_and_tag(ascii_char([?>, ?<]), :op)
      |> unwrap_and_tag(integer(min: 1), :val)
      |> ignore(string(":"))
      |> unwrap_and_tag(label, :jump)
      |> reduce({Map, :new, []})

    workflow =
      empty()
      |> unwrap_and_tag(label, :label)
      |> ignore(string("{"))
      |> tag(repeat_1(rule |> ignore(string(","))), :rules)
      |> unwrap_and_tag(label, :default)
      |> ignore(string("}"))
      |> reduce({Map, :new, []})

    part =
      empty()
      |> ignore(string("{"))
      |> sep_by_1(
        ascii_char([?x, ?m, ?a, ?s])
        |> ignore(string("="))
        |> integer(min: 1)
        |> reduce({List, :to_tuple, []}),
        string(",")
      )
      |> ignore(string("}"))
      |> reduce({Map, :new, []})

    workflows = repeat_1(workflow |> ignore(eol()))
    parts = repeat_1(part |> ignore(eol_or_eos()))

    defparser :parse,
              tag(workflows, :workflows)
              |> ignore(eol())
              |> tag(parts, :parts)
              |> reduce({Map, :new, []})
  end

  @doc """
  Part 1: Score all parts that are accepted

      iex> Advent2023.Day19.part1(Util.read_input!(2023, 19))
      476889
  """
  def part1(input) do
    [%{workflows: workflows, parts: parts}] = input |> InputParser.parse!()
    workflow_map = Map.new(workflows, fn w -> {w.label, w} end)

    parts
    |> Enum.filter(fn part -> check_part(part, "in", workflow_map) == "A" end)
    |> Enum.map(fn part -> Map.values(part) |> Enum.sum() end)
    |> Enum.sum()
  end

  def check_part(part, workflow_label, workflow_map) do
    workflow = workflow_map[workflow_label]

    result =
      Enum.find_value(workflow.rules, workflow.default, fn
        %{:op => ?<} = rule -> part[rule.prop] < rule.val && rule.jump
        %{:op => ?>} = rule -> part[rule.prop] > rule.val && rule.jump
      end)

    case result do
      "A" -> result
      "R" -> result
      next -> check_part(part, next, workflow_map)
    end
  end

  @doc """
  Part 2: Try all combinations of x, m, a, s between 1..4000

      iex> Advent2023.Day19.part2(Util.read_input!(2023, 19))
      132380153677887
  """
  def part2(input) do
    [%{workflows: workflows}] = input |> InputParser.parse!()
    workflow_map = Map.new(workflows, fn w -> {w.label, w} end)
    init_part = %{?x => 1..4000, ?m => 1..4000, ?a => 1..4000, ?s => 1..4000}

    check_part_range(init_part, "in", workflow_map)
    |> Enum.filter(&match?({_, "A"}, &1))
    |> Enum.map(fn {part, _} -> Map.values(part) |> Enum.map(&Range.size/1) |> Enum.product() end)
    |> Enum.sum()
  end

  def check_part_range(part, workflow_label, workflow_map) do
    workflow = workflow_map[workflow_label]
    jumps = check_part_range_rule(part, workflow.rules, workflow.default)

    Enum.flat_map(jumps, fn
      {part, "A"} -> [{part, "A"}]
      {part, "R"} -> [{part, "R"}]
      {part, next} -> check_part_range(part, next, workflow_map)
    end)
  end

  def check_part_range_rule(part, [], default) do
    %{part => default}
  end

  def check_part_range_rule(part, [rule | rest], default) do
    min..max = part[rule.prop]

    # Evaluate the rule on the range, splitting into two parts (one of which
    # may be empty) where one part satisfies the rule and the other does not.
    {true_part, false_part} =
      case rule do
        %{:op => ?<} ->
          cond do
            # whole part is < value
            max < rule.val ->
              {part, nil}

            # whole part is > value
            rule.val < min ->
              {nil, part}

            # split where left is < value and right is > value
            true ->
              {
                %{part | rule.prop => min..(rule.val - 1)},
                %{part | rule.prop => rule.val..max}
              }
          end

        %{:op => ?>} ->
          cond do
            # whole part is > value
            min > rule.val ->
              {part, nil}

            # whole part is < value
            rule.val > max ->
              {nil, part}

            # split where left is > value and right is < value
            true ->
              {
                %{part | rule.prop => (rule.val + 1)..max},
                %{part | rule.prop => min..rule.val}
              }
          end
      end

    case {true_part, false_part} do
      {nil, _} ->
        check_part_range_rule(false_part, rest, default)

      {_, nil} ->
        %{true_part => rule.jump}

      _ ->
        Map.merge(%{true_part => rule.jump}, check_part_range_rule(false_part, rest, default))
    end
  end
end
