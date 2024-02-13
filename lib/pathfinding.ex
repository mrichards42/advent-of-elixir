defmodule Pathfinding do
  @type v :: term()
  @type path :: [v]
  @type cost :: non_neg_integer()
  @type opts :: [goal: :first | :every]
  @type neighbors_fn :: (v -> [v])
  @type cost_fn :: (v, v -> cost)

  # Using a gb_set as a priority is not the fastest (since we can't do
  # decrease-priority and have to instead filter out seen nodes after we pop
  # the smallest), but it's pretty darn close, and it's so much less code than
  # writing a priority queue implementation from scratch that has a decrease
  # priority operation.
  @opaque priority_queue(element) :: :gb_sets.set(element)

  @doc """
  Finds the shortest path between any of `start` nodes and any of `goal` nodes.
  Returns a list of {cost, path} tuples for each goal node that was reached.

  With `goal: :first`, stops after reaching the first goal in the goals list.
  Otherwise waits until all goals have been reached.
  """
  @spec dijkstra(start :: v | [v], goal :: v | [v], neighbors_fn, cost_fn, opts) :: [{cost, path}]
  def dijkstra(start, goal, neighbors_fn, cost_fn, opts_ \\ []) do
    opts = Keyword.validate!(opts_, goal: :every)
    starts = Enum.map(List.wrap(start), fn node -> {0, node, []} end)
    goals = List.wrap(goal)
    visited = %{}

    do_dijkstra(
      :gb_sets.from_list(starts),
      visited,
      goals,
      neighbors_fn,
      cost_fn,
      opts
    )
  end

  @doc """
  Breadth-first search implemented as dijkstra where weights are always 1.
  """
  @spec bfs(start :: v | [v], goal :: v | [v], neighbors_fn) :: [{cost, path}]
  def bfs(start, goal, neighbors_fn, opts \\ []) do
    dijkstra(start, goal, neighbors_fn, &unweighted_cost/2, opts)
  end

  defp unweighted_cost(_, _), do: 1

  @spec do_dijkstra(
          frontier :: priority_queue({cost, v, path}),
          visited :: %{v => {cost, v}},
          goals :: [v],
          neighbors_fn,
          cost_fn,
          opts
        ) :: [{cost, path}]
  defp do_dijkstra(frontier, visited, goals, neighbors_fn, cost_fn, opts) do
    {{cost, node, path}, rest_frontier} = :gb_sets.take_smallest(frontier)

    if Map.has_key?(visited, node) do
      # already seen this node, skip it
      do_dijkstra(rest_frontier, visited, goals, neighbors_fn, cost_fn, opts)
    else
      new_frontier =
        neighbors_fn.(node)
        |> Enum.reject(&Map.has_key?(visited, &1))
        |> Enum.reduce(rest_frontier, fn neighbor, new_frontier ->
          :gb_sets.insert(
            {cost + cost_fn.(node, neighbor), neighbor, [node | path]},
            new_frontier
          )
        end)

      new_visited = Map.put(visited, node, {cost, path})

      if Enum.member?(goals, node) do
        goal_ret = {cost, Enum.reverse([node | path])}
        new_goal = Enum.reject(goals, &(&1 == node))

        if Enum.empty?(new_goal) or opts[:goal] == :first do
          [goal_ret]
        else
          [
            goal_ret
            | do_dijkstra(new_frontier, new_visited, new_goal, neighbors_fn, cost_fn, opts)
          ]
        end
      else
        do_dijkstra(new_frontier, new_visited, goals, neighbors_fn, cost_fn, opts)
      end
    end
  end
end
