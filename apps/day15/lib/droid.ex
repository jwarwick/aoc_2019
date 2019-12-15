defmodule Droid do
  @moduledoc """
  Intcode Repair Droid
  """

  defstruct map: %{{0, 0} => :empty}, loc: {0, 0}, last_attempt: nil, oxygen: nil, steps: 0

  def print({map, loc}) do
    pts = Map.keys(map)

    {min_x, max_x} = Enum.map(pts, fn {x, _y} -> x end) |> Enum.min_max()
    {min_y, max_y} = Enum.map(pts, fn {_x, y} -> y end) |> Enum.min_max()

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        cond do
          {x, y} == loc -> IO.write(print_char(:droid))
          {x, y} == {0, 0} -> IO.write("S")
          {x, y} -> IO.write(print_char(Map.get(map, {x,y}, :unknown)))
        end
      end
      IO.write("\n")
    end
    IO.write("------------------------------\n\n\n")
    :ok
  end

  defp print_char(:unknown), do: " "
  defp print_char(:empty), do: "."
  defp print_char(:wall), do: "#"
  defp print_char(:oxygen), do: "O"
  defp print_char(:droid), do: "D"

  @doc """
  Build a map of the space
  """
  def explore(str) do
    {:ok, _pid} = Agent.start_link(fn -> %Droid{} end, name: __MODULE__)
    code = Intcode.load(str)
    Intcode.run(code, [], &movement/0, &status/1)
    result = Agent.get(__MODULE__, fn state -> {state.map, state.oxygen} end)
    Agent.stop(__MODULE__)
    shortest_path(result)
  end

  defp shortest_path({map, goal}) do
    nodes = Enum.filter(map, fn {_loc, type} -> type == :empty || type == :oxygen end)
            |> Enum.map(fn {loc, _type} -> loc end)
            |> MapSet.new()

    g = Graph.new()
        |> add_edges(MapSet.to_list(nodes), nodes)

    path = Graph.get_shortest_path(g, {0, 0}, goal)
    Enum.count(path) - 1
  end

  defp add_edges(g, [], _nodes), do: g
  defp add_edges(g, [loc | rest], nodes) do
    Enum.take_random(1..4, 50)
    |> Enum.uniq()
    |> Enum.map(fn dir -> next_loc(loc, dir) end)
    |> Enum.filter(&(MapSet.member?(nodes, &1)))
    |> Enum.reduce(g, fn (n, acc) -> Graph.add_edge(acc, loc, n) |> Graph.add_edge(n, loc) end)
    |> add_edges(rest, nodes)
  end

  def movement do
    {curr, steps} = Agent.get(__MODULE__, fn state -> {{state.map, state.loc}, state.steps} end)
    if steps >= 100_000 do
      print(curr)
      :halt
    else
      {next, dir} = get_next_move(curr)
      Agent.update(__MODULE__, fn state -> %Droid{state | last_attempt: next, steps: steps + 1} end)
      dir
    end
  end

  @north 1
  @south 2
  @west 3
  @east 4

  defp get_next_move({map, loc}) do
    Enum.map(1..4, fn x -> {next_loc(loc, x), x} end)
    |> make_choice(loc, map)
  end
    
  defp make_choice([], loc, _map) do
    dir = Enum.random([@north, @south, @east, @west])
    next = next_loc(loc, dir)
    {next, dir}
  end

  defp make_choice([{next, dir} | rest], loc, map) do
    kind = Map.get(map, next, :unvisited)
    if kind == :unvisited do
      {next, dir}
    else
      make_choice(rest, loc, map)
    end
  end

  defp next_loc({x, y}, @north), do: {x, y-1}
  defp next_loc({x, y}, @south), do: {x, y+1}
  defp next_loc({x, y}, @east), do: {x-1, y}
  defp next_loc({x, y}, @west), do: {x+1, y}

  @wall 0
  @empty 1
  @oxygen 2

  def status(@wall) do
    set_next_location(:wall)
  end

  def status(@empty) do
    set_next_location(:empty)
    update_location()
  end

  def status(@oxygen) do
    set_next_location(:oxygen)
    update_location()
  end

  defp set_next_location(kind) do
    {map, next} = Agent.get(__MODULE__, fn state -> {state.map, state.last_attempt} end)
    map = Map.put(map, next, kind)
    Agent.update(__MODULE__, fn state -> %Droid{state | map: map} end)
    if kind == :oxygen do
      Agent.update(__MODULE__, fn state -> %Droid{state | oxygen: next} end)
    end
  end

  defp update_location() do
    next = Agent.get(__MODULE__, fn state -> state.last_attempt end)
    Agent.update(__MODULE__, fn state -> %Droid{state | loc: next} end)
  end
end
