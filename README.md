# Advent of Elixir


## Setup a day

Generate elixir files:

```bash
mix gen_day         # current day
mix gen_day 2023 1  # a specific day
```

Download your input and stick it next to the module, e.g.
`lib/advent_2023/day_01.txt`

## Run

```bash
mix test                                  # everything
mix test test/advent_2023                 # a year
mix test test/advent_2023/day_01_test.exs # a single day

# or run this to test just modules that have changed since the last run
mix test --stale
```
