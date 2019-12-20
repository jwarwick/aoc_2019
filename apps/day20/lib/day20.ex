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
  Compute path length in a map
  """
  def path(str, start, goal) do
    {links, map} = parse(str)
    g = make_graph(map)
    start = String.to_charlist(start) |> Enum.sort()
    goal = String.to_charlist(goal) |> Enum.sort()
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

  defp node_val([{_, c1}, {_, c2}, {loc, "."}]) do
    {loc, String.to_charlist(c1 <> c2) |> Enum.sort()}
  end
  defp node_val([{loc, "."}, {_, c1}, {_, c2}]) do
    {loc, String.to_charlist(c2 <> c1) |> Enum.sort()}
  end

  defp get_neigh(map, {x, y}) do
    [{x+1, y}, {x-1, y}, {x, y+1}, {x, y-1}]
    |> Enum.map(fn k -> {k, Map.get(map, k)} end)
    |> Enum.filter(fn {_k, v} -> v != nil end)
  end

end
