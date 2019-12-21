defmodule Day18 do
  @moduledoc """
  AoC 2019, Day 18 - Many-Worlds Interpretation
  """

  defmodule Maze do
    defstruct map: %{}, start: []
  end

  @doc """
  Shortest path that collects all the keys
  """
  def part1 do
    Util.priv_file(:day18, "day18_input.txt")
    |> File.read!()
    |> shortest_path()
  end

  @doc """
  Shortest path the multi-chamber maze that collects all the keys
  """
  def part2 do
    Util.priv_file(:day18, "day18_part2_input.txt")
    |> File.read!()
    |> multi_shortest_path()
  end

  @doc """
  Return the shortest path through the multi-chamber maze
  """
  def multi_shortest_path(str) do
    maze = parse(str)
    key_cnt = Map.values(maze.map) |> Enum.filter(fn {t, _v, _n} -> t == :key end) |> Enum.count()
    visited = Enum.map(maze.start, &({&1, MapSet.new()}))
              |> MapSet.new()
    q = Enum.map(maze.start, &({&1, maze.start -- [&1], 0, MapSet.new()}))
        |> :queue.from_list()
    multi_reachable(maze.map, key_cnt, visited, q)
  end

  defp multi_reachable(map, num_keys, visited, queue) do
    # IO.puts "\n\nQueue: #{inspect :queue.to_list(queue)}"
    {{:value, {curr, rest, steps, keys}}, queue} = :queue.out(queue)
    if MapSet.size(keys) == num_keys do
      steps
    else
      n = neighbors(map, curr)
      # IO.puts "Neighbors: #{inspect n}"

      {new_v, new_q} = Enum.reduce(n, {visited, queue},
                                   fn (loc, acc = {v, q}) ->
                                     # IO.puts "N: #{inspect loc}"
                                     cond do
                                       MapSet.member?(visited, {loc, keys}) ->
                                         # IO.puts "\tAlready visited"
                                         acc
                                       !unlocked(map, keys, loc) ->
                                         # IO.puts "\tDoor locked"
                                         acc
                                       true ->
                                         # IO.puts "\tValid loc"
                                         new_keys = add_keys(map, keys, loc)
                                         # IO.puts "\tKeys: #{inspect new_keys}"
                                         add_combos(new_keys, v, q, loc, rest, steps)
                                     end
                                   end)
      multi_reachable(map, num_keys, new_v, new_q)
    end
  end

  defp add_combos(keys, visited, queue, curr, [a, b, c], steps) do
    add_combo({visited, queue}, keys, steps, curr, [a, b, c])
    |> add_combo(keys, steps, a, [curr, b, c])
    |> add_combo(keys, steps, b, [a, curr, c])
    |> add_combo(keys, steps, c, [a, b, curr])
  end

  defp add_combo({v, q}, keys, steps, curr, rest) do
    if !MapSet.member?(v, {curr, keys}) do
      {MapSet.put(v, {curr, keys}), :queue.in({curr, rest, steps+1, keys}, q)}
    else
      {v, q}
    end
  end

  defp unlocked(map, keys, loc) do
    {type, val, _neigh} = Map.get(map, loc)
    type != :door || MapSet.member?(keys, val)
  end

  defp add_keys(map, keys, loc) do
    {type, val, _neigh} = Map.get(map, loc)
    if type == :key do
      MapSet.put(keys, val)
    else
      keys
    end
  end

  @doc """
  Return the shortest path through the maze
  """
  def shortest_path(str) do
    maze = parse(str)
    start = hd(maze.start)
    key_cnt = Map.values(maze.map) |> Enum.filter(fn {t, _v, _n} -> t == :key end) |> Enum.count()
    visited = MapSet.new([{start, MapSet.new()}])
    q = :queue.from_list([{start, 0, MapSet.new()}])
    reachable(maze.map, key_cnt, visited, q)
  end

  defp reachable(map, num_keys, visited, queue) do
    {{:value, {loc, depth, keys}}, queue} = :queue.out(queue)
    if MapSet.size(keys) == num_keys do
      depth
    else
      {_type, _val, neigh} = Map.get(map, loc)
      {new_v, new_q} = Enum.reduce(neigh, {visited, queue},
                                   fn (nloc, {v, q}) ->
                                     val = Map.get(map, nloc) 
                                     update(nloc, val, keys, depth, v, q)
                                   end)
      reachable(map, num_keys, new_v, new_q)
    end
  end

  defp update(loc, {:space, _val, _neigh}, keys, depth, visited, queue) do
    if !MapSet.member?(visited, {loc, keys}) do
      {MapSet.put(visited, {loc, keys}), :queue.in({loc, depth+1, keys}, queue)}
    else
      {visited, queue}
    end
  end

  defp update(loc, {:door, val, neigh}, keys, depth, visited, queue) do
    if MapSet.member?(keys, val) do
      update(loc, {:space, val, neigh}, keys, depth, visited, queue)
    else
      {visited, queue}
    end
  end

  defp update(loc, {:key, val, neigh}, keys, depth, visited, queue) do
    keys = MapSet.put(keys, val)
    if !MapSet.member?(visited, {loc, keys}) do
      update(loc, {:space, val, neigh}, keys, depth, visited, queue)
    else
      {visited, queue}
    end
  end

  defp parse(str) do
    maze = String.split(str, "\n", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(%Maze{}, &parse_row/2)
    new_map = Enum.reduce(Map.keys(maze.map), %{}, &(add_neighbors(maze.map, &1, &2)))
    %Maze{maze | map: new_map}
  end

  defp add_neighbors(map, loc, acc) do
    {type, val, _} = Map.get(map, loc)
    neigh = neighbors(map, loc)
    Map.put(acc, loc, {type, val, neigh})
  end

  defp neighbors(map, {x, y}) do
    [{x+1, y}, {x-1, y}, {x, y+1}, {x, y-1}]
    |> Enum.filter(&(Map.has_key?(map, &1)))
  end

  defp parse_row({vals, row_num}, acc), do: parse_row({0, row_num}, String.to_charlist(vals), acc)

  defp parse_row(_loc, [], acc), do: acc
  defp parse_row(loc = {col, row}, [head | rest], acc) do
    new_acc = parse_entry(loc, head, acc)
    parse_row({col+1, row}, rest, new_acc)
  end

  defp parse_entry(_loc, ?#, acc), do: acc
  defp parse_entry(loc, ?., acc), do: add_valid(loc, {:space, nil}, acc)
  defp parse_entry(loc, ?@, acc) do
    new = add_valid(loc, {:space, nil}, acc)
    %Maze{new | start: [loc | new.start]}
  end
  defp parse_entry(loc, val, acc) do
    type = if <<val>> == String.upcase(<<val>>), do: :door, else: :key
    v = String.downcase(<<val>>) |> String.to_charlist() |> hd()
    add_valid(loc, {type, v}, acc)
  end

  defp add_valid(loc, {type, v}, acc), do: %Maze{acc | map: Map.put(acc.map, loc, {type, v, []})}

  def print(maze) do
    {{min_x, max_x}, {min_y, max_y}} = bounds(maze.map)
    for y <- min_y..max_y do
      for x <- min_x..max_x do
        if {x, y} in maze.start do
          IO.write('@')
        else
          IO.write(char(Map.get(maze.map, {x, y}, {:wall, nil, []})))
        end
      end
      IO.write("\n")
    end
    IO.write("\n\n\n")
  end

  defp char({:space, _, _}), do: '.'
  defp char({:wall, _, _}), do: '#'
  defp char({:key, val, _}), do: <<val>>
  defp char({:door, val, _}), do: String.upcase(<<val>>)

  defp bounds(map) do
    pts = Map.keys(map)
    x = Enum.map(pts, fn {x, _y} -> x end) |> Enum.min_max()
    y = Enum.map(pts, fn {_x, y} -> y end) |> Enum.min_max()
    {x, y}
  end
end
