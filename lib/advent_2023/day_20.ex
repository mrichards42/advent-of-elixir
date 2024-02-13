defmodule Advent2023.Day20 do
  @moduledoc """
  Day 20: Pulse Propagation
  """

  defmodule InputParser do
    import NimbleParsec
    import ParserUtil

    label = ascii_string([?a..?z], min: 1)

    module =
      optional(unwrap_and_tag(choice([string("&"), string("%")]), :type))
      |> unwrap_and_tag(label, :label)
      |> ignore(string(" -> "))
      |> tag(sep_by_1(label, string(", ")), :outputs)
      |> reduce({Map, :new, []})

    defparser :parse, repeat_1(module |> ignore(eol_or_eos()))
  end

  def init_machine(modules_list) do
    modules = Map.new(modules_list, fn m -> {m.label, m} end)

    reverse_edges =
      for %{label: input, outputs: outputs} <- modules_list,
          output <- outputs do
        {input, output}
      end
      |> Enum.group_by(&elem(&1, 1))
      |> Map.new(fn {output, entries} -> {output, Enum.map(entries, &elem(&1, 0))} end)

    # there are also some sinks that have no outputs and so never show up on
    # the left side of the input
    sinks = Enum.reject(Map.keys(reverse_edges), &Map.has_key?(modules, &1))

    modules =
      Map.merge(modules, Map.new(sinks, fn sink -> {sink, %{type: "sink", label: sink}} end))

    state =
      Map.new(modules, fn
        {label, %{type: "%"}} ->
          {label, :off}

        {label, %{type: "&", label: label}} ->
          {label, Map.new(reverse_edges[label], fn input -> {input, :low} end)}

        {label, _} ->
          {label, nil}
      end)

    {modules, Map.merge(state, %{high: 0, low: 0})}
  end

  @doc """
  Part 1: Number of high and low pulses after running 1000 times

      iex> Advent2023.Day20.part1(Util.read_input!(2023, 20))
      788081152
  """
  def part1(input) do
    {modules, state} = input |> InputParser.parse!() |> init_machine()

    final_state =
      Stream.iterate(state, &run(modules, &1))
      |> Enum.at(1000)

    final_state.high * final_state.low
  end

  @doc """
  Part 2: Number of button pushes until rx gets a low pulse

      iex> Advent2023.Day20.part2(Util.read_input!(2023, 20))
      224602011344203
  """
  def part2(input) do
    {modules, state} = input |> InputParser.parse!() |> init_machine()

    # The input is 4 12-bit counter circuits wired up to a conjunction. In
    # order to make sure we hit all possible states for each counter, we need
    # to run this 2^12 (= 4096) times
    all_states =
      Stream.iterate(state, &run(modules, &1))
      |> Enum.take(2 ** 12)

    # This is a lot of typing, but it's how I tried to do it originally. The
    # easier solution (which I did actually implement when I had a typo in this
    # list) is to check all the inputs to the conjunction "xm" (which feeds
    # into "rx") and see what cycle they first sent a high pulse. Once I found
    # the typo here this solution worked, so I'm going with it.
    counters = [
      ["bv", "mf", "pk", "vq", "jd", "gm", "rl", "nc", "km", "fc", "vv", "vn"],
      ["pt", "pf", "hv", "hj", "ch", "xt", "lh", "sr", "vr", "xq", "rr", "tr"],
      ["gv", "kq", "nv", "mb", "qg", "sn", "nk", "vk", "hz", "mp", "nn", "cv"],
      ["tp", "bj", "zc", "qv", "kf", "mr", "lq", "ql", "gr", "qh", "nm", "js"]
    ]

    read_counter = fn state, bit_modules ->
      Enum.map(bit_modules, fn bit -> if state[bit] == :on, do: 1, else: 0 end)
      |> Enum.reverse()
      |> Enum.join()
      |> String.to_integer(2)
    end

    counters
    |> Enum.map(fn counter ->
      Enum.max(Enum.map(all_states, &read_counter.(&1, counter)))
    end)
    |> Enum.map(&Util.inc/1)
    |> Enum.reduce(&Math.lcm/2)
  end

  def run(modules, state) do
    run_next_pulse(modules, state, :queue.from_list([{"button", "broadcaster", :low}]))
  end

  def run_next_pulse(modules, state, queue) do
    case :queue.out(queue) do
      {{:value, {from, to, pulse}}, rest_queue} ->
        module = modules[to]

        {next_state, next_pulse} =
          run_module(module, {from, pulse}, Map.update!(state, pulse, &Util.inc/1))

        if next_pulse == nil do
          run_next_pulse(modules, next_state, rest_queue)
        else
          queued_pulses =
            :queue.from_list(Enum.map(module.outputs, &{to, &1, next_pulse}))

          run_next_pulse(modules, next_state, :queue.join(rest_queue, queued_pulses))
        end

      {:empty, _} ->
        state
    end
  end

  ## Flip flops

  def run_module(%{type: "%", label: label}, {_, :low}, state) do
    case state[label] do
      :off -> {%{state | label => :on}, :high}
      :on -> {%{state | label => :off}, :low}
    end
  end

  def run_module(%{type: "%"}, {_, :high}, state) do
    # noop on high pulse
    {state, nil}
  end

  ## Conjunction

  def run_module(%{type: "&", label: label}, {from, pulse}, state) do
    new_state = %{state[label] | from => pulse}

    next_pulse =
      if Enum.all?(new_state, &match?({_, :high}, &1)) do
        :low
      else
        :high
      end

    {%{state | label => new_state}, next_pulse}
  end

  ## Special module types

  def run_module(%{label: "broadcaster"}, {_, pulse}, state) do
    {state, pulse}
  end

  def run_module(%{type: "sink"}, _, state) do
    {state, nil}
  end
end
