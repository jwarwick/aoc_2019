defmodule Day20 do
  @moduledoc """
  AoC 2019, Day 20 - Donut Maze
  """

  @doc """
  Steps to get from AA to ZZ
  """
  def part1 do
    Util.priv_file(:day20, "day20_input.txt")
    |> File.read!()
    |> path("AA", "ZZ")
  end

  @doc """
  Recursive maze steps from AA to ZZ
  """
  def part2 do
    Util.priv_file(:day20, "day20_input.txt")
    |> File.read!()
    |> recursive_path("AA", "ZZ")
  end

  @doc """
  Compute recursive path length in a map
  """
  def recursive_path(str, start, goal) do
    {links, map} = parse(str)
    start = String.to_charlist(start)
    goal = String.to_charlist(goal)
    start_v = Map.get(links, start) |> elem(1)
    goal_v = Map.get(links, goal) |> elem(1)
    b = bounds(map)
    bfs(map, b, {goal_v, 0}, :queue.from_list([{{start_v, 0}, 0}]), MapSet.new([{start_v, 0}]))
  end

  defp bounds(map) do
    pts = Map.keys(map)
    x = Enum.map(pts, fn {x, _y} -> x end) |> Enum.min_max()
    y = Enum.map(pts, fn {_x, y} -> y end) |> Enum.min_max()
    {x, y}
  end

  defp bfs(map, b, goal, q, visited) do
    {{:value, {target = {loc, depth}, steps}}, q} = :queue.out(q)
    if target == goal do
      steps
    else
      {new_q, new_visited} = recursive_neighbors(map, b, q, visited, loc, depth, steps)
      bfs(map, b, goal, new_q, new_visited)
    end
  end

  defp recursive_neighbors(map, b, q, visited, loc, depth, steps) do
    {new_q, new_v} = add_link({q, visited}, map, b, depth, loc, steps)

    get_neigh(map, loc)
    |> Enum.filter(&(first_level(&1, depth, b)))
    |> Enum.filter(fn {loc, _rest} -> !MapSet.member?(visited, {loc, depth}) end)
    |> Enum.map(fn {loc, _type} -> {loc, depth} end)
    |> Enum.reduce({new_q, new_v},
                   fn (item, {new_q, new_v}) ->
                     {:queue.in({item, steps+1}, new_q), MapSet.put(new_v, item)}
                   end)
  end

  defp add_link(curr, map, b, depth, loc, steps), do: add_link(curr, b, depth, {loc, Map.get(map, loc)}, steps)

  defp add_link(curr, _b, _depth, {_loc, {:space, _, _}}, _steps), do: curr
  defp add_link(curr, _b, _depth, {_loc, {:link, _, nil}}, _steps), do: curr
  defp add_link(curr = {q, v}, {{min_x, max_x}, {min_y, max_y}}, depth, {{x, y}, {:link, _str, link}}, steps) do
    depth = if x == min_x || x == max_x || y == min_y || y == max_y do
      depth - 1
    else
      depth + 1
    end
    n = {link, depth}
    if MapSet.member?(v, n) do
      curr
    else
      {:queue.in({n, steps+1}, q), MapSet.put(v, n)}
    end
  end

  defp first_level({{x, y}, {:link, str, _link}}, 0, {{min_x, max_x}, {min_y, max_y}}) do
    str in ['AA', 'ZZ'] || (x != min_x && x != max_x && y != min_y && y != max_y)
  end
  defp first_level({_loc, {:link, str, _link}}, _depth, _b) do
    str not in ['AA', 'ZZ']
  end
  defp first_level(_v, _d, _b), do: true

  @doc """
  Compute path length in a map
  """
  def path(str, start, goal) do
    {links, map} = parse(str)
    g = make_graph(map)
    start = String.to_charlist(start)
    goal = String.to_charlist(goal)
    start_v = Map.get(links, start) |> elem(1)
    goal_v = Map.get(links, goal) |> elem(1)
    path = Graph.get_shortest_path(g, start_v, goal_v)
    Enum.count(path) - 1
  end

  defp make_graph(map) do
    Map.keys(map)
    |> Enum.reduce(Graph.new(), &(add_node(&1, &2, map)))
  end

  defp add_node(k, g, map) do
    {type, _str, link} = Map.get(map, k)
    g = if type == :link && link != nil do
      Graph.add_edge(g, k, link)
      |> Graph.add_edge(link, k)
    else
      g
    end

    get_neigh(map, k)
    |> Enum.reduce(g, fn ({loc, {v, _, _}}, acc) ->
      if v == :space do
        Graph.add_edge(acc, k, loc)
        |> Graph.add_edge(loc, k)
      else
        acc
      end
    end)
  end

  @doc """
  Parse a maze
  """
  def parse(str) do
    String.split(str, "\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(&parse_row/1)
    |> List.flatten()
    |> Enum.filter(fn {_loc, v} -> v != "#" and v != " " end)
    |> Enum.into(%{})
    |> link_portals()
  end

  defp parse_row({row, num}) do
    String.graphemes(row)
    |> Enum.with_index()
    |> Enum.map(fn {c, col} -> {{col, num}, c} end)
  end

  defp link_portals(map) do
    letters = Map.keys(map)
              |> Enum.reduce(%{},
                             fn (k, acc) ->
                               v = Map.get(map, k)
                               if v != "." do
                                 Map.put(acc, k, v)
                               else
                                 acc
                               end
                             end)

    neighbors = Map.keys(letters)
                |> Enum.reduce([],
                               fn (k, acc) ->
                                 us = Map.get(map, k)
                                 lst = get_neigh(map, k)
                                 if Enum.count(lst) == 2 do
                                   [{{k, us}, lst} | acc]
                                 else
                                   acc
                                 end
                               end
                )

    stripped = Map.keys(map)
               |> Enum.reduce(%{},
                              fn (k, acc) ->
                                v = Map.get(map, k)
                                if v == "." do
                                  Map.put(acc, k, {:space, nil, nil})
                                else
                                  acc
                                end
                              end)


    {links, map} = Enum.reduce(neighbors,
                               {%{}, stripped},
                               fn ({a, [b, c]}, {links, whole}) ->
                                 {p, val} = Enum.sort([a, b, c])
                                            |> node_val()
                                            whole = Map.put(whole, p, {:link, val, nil})
                                            v = Map.get(links, val)
                                            links = if v == nil do
                                              Map.put(links, val, {val, p, nil})
                                            else
                                              {_val, other_p, _} = v
                                              Map.put(links, val, {val, p, other_p})
                                            end
                                            {links, whole}
                               end)

    map = Map.keys(map)
          |> Enum.reduce(%{},
                         fn (k, acc) ->
                           v = {type, str, _} = Map.get(map, k)
                           if type == :link do
                             {str, loc1, loc2} = Map.get(links, str)
                             other_loc = if loc1 == k, do: loc2, else: loc1
                             Map.put(acc, k, {:link, str, other_loc})
                           else
                             Map.put(acc, k, v)
                           end
                         end)

    {links, map}
  end

  defp node_val([{{x, _}, c1}, {{x, _}, c2}, {loc, "."}]) do
    {loc, String.to_charlist(c1 <> c2)}
  end
  defp node_val([{loc, "."}, {{x, _}, c1}, {{x, _}, c2}]) do
    {loc, String.to_charlist(c1 <> c2)}
  end
  defp node_val([{{_, y}, c1}, {{_, y}, c2}, {loc, "."}]) do
    {loc, String.to_charlist(c1 <> c2)}
  end
  defp node_val([{loc, "."}, {{_, y}, c1}, {{_, y}, c2}]) do
    {loc, String.to_charlist(c1 <> c2)}
  end

  defp get_neigh(map, {x, y}) do
    [{x+1, y}, {x-1, y}, {x, y+1}, {x, y-1}]
    |> Enum.map(fn k -> {k, Map.get(map, k)} end)
    |> Enum.filter(fn {_k, v} -> v != nil end)
  end

end
