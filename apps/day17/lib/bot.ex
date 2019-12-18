defmodule Bot do
  @moduledoc """
  Intcode Wired Cameras and Vacuum Bot
  """

  defstruct map: %{}, loc: {0, 0}, bot: nil, dir: nil, output: []

  def print(map) do
    {{min_x, max_x}, {min_y, max_y}} = bounds(map)

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        IO.write(print_char(Map.get(map, {x, y}, :empty)))
      end

      IO.write("\n")
    end

    :ok
  end

  defp bounds(map) do
    pts = Map.keys(map)

    x = Enum.map(pts, fn {x, _y} -> x end) |> Enum.min_max()
    y = Enum.map(pts, fn {_x, y} -> y end) |> Enum.min_max()
    {x, y}
  end

  defp print_char(:empty), do: "."
  defp print_char(:scaffold), do: "#"
  defp print_char(:bot), do: "B"

  @doc """
  Return the dust captured on a tour of the scaffold
  """
  def tour(path) do
    result = build_map(path)
    route = wander(result)
    {cnt, lst} = Enum.reduce(route, {0, []}, &collapse/2)
    [_hd | route] = [cnt | lst] |> Enum.reverse()
    route = Enum.join(route, ",")
    IO.puts "ROUTE: #{inspect route}"
    # "R,4,L,12,L,8,R,4,L,8,R,10,R,10,R,6,R,4,L,12,L,8,R,4,R,4,R,10,L,12,R,4,L,12,L,8,R,4,L,8,R,10,R,10,R,6,R,4,L,12,L,8,R,4,R,4,R,10,L,12,L,8,R,10,R,10,R,6,R,4,R,10,L,12"
    # Built pattern by hand from the route string....
    main = "A,B,A,C,A,B,A,C,B,C"
    a = "R,4,L,12,L,8,R,4"
    b = "L,8,R,10,R,10,R,6"
    c = "R,4,R,10,L,12"
    result = evaulate(path, main, a, b, c)
    val = List.last(result)
    if val == ?\n, do: nil, else: val
  end

  def collapse(1, {cnt, lst}) do
    {cnt+1, lst}
  end

  def collapse(x, {cnt, lst}) do
    {0, [x | [Integer.to_string(cnt) | lst]]}
  end

  def wander(%Bot{map: map, bot: loc, dir: d}) do
    heading = dir(d)
    num_cells = Map.keys(map) |> Enum.count()
    step(map, loc, heading, num_cells, [loc], [])
  end

  def step(map, loc, heading, needed, seen, acc) do
    f = forward(loc, heading)
    left = forward(loc, turn(heading, :left))
    right = forward(loc, turn(heading, :right))
    cond do
      Map.has_key?(map, f) ->
        new_seen = [loc | seen] |> Enum.uniq()
        step(map, f, heading, needed, new_seen, [1 | acc])
      Map.has_key?(map, left) ->
        step(map, loc, turn(heading, :left), needed, seen, ["L" | acc])
      Map.has_key?(map, right) ->
        step(map, loc, turn(heading, :right), needed, seen, ["R" | acc])
      true -> Enum.reverse(acc)
    end
  end

  def forward({x, y}, :north), do: {x, y-1}
  def forward({x, y}, :south), do: {x, y+1}
  def forward({x, y}, :east), do: {x+1, y}
  def forward({x, y}, :west), do: {x-1, y}

  defp evaulate(path, main, a, b, c) do
    {:ok, _pid} = Agent.start_link(fn -> %Bot{} end, name: __MODULE__)
    code = Intcode.load(path) |> Intcode.poke(0, 2)
    input = Enum.join([main, a, b, c, "n\n"], "\n") |> String.to_charlist()
    Intcode.run(code, input, nil, &display_output/1)
    result = Agent.get(__MODULE__, fn state -> state.output end) |> Enum.reverse()
    Agent.stop(__MODULE__)
    result
  end

  # Appears to print the starting map, then the prompts,
  # then the final map, then the final output (if the robot stayed on the scaffold)
  defp display_output(val) do
    output = Agent.get(__MODULE__, fn state -> state.output end)
    Agent.update(__MODULE__, fn state -> %Bot{state | output: [val | output]} end)
  end

  defp dir(?^), do: :north
  defp dir(?v), do: :south
  defp dir(?<), do: :east
  defp dir(?>), do: :west

  for {curr, dir, new}  <- [{:north, :left, :west},
                             {:north, :right, :east},
                             {:south, :left, :east},
                             {:south, :right, :west},
                             {:east, :right, :south},
                             {:east, :left, :north},
                             {:west, :left, :south},
                             {:west, :right, :north}] do
                               def turn(unquote(curr), unquote(dir)), do: unquote(new)
                             end

  @doc """
  Compute the alignment value of the image
  """
  def alignment(path) do
    result = build_map(path)
    print(result.map)
    compute_params(result.map)
  end

  def compute_params(map) do
    Map.keys(map)
    |> get_intersections(map, [])
    |> Enum.reduce(0, fn {x, y}, acc -> x * y + acc end)
  end

  defp get_intersections([], _map, acc), do: acc

  defp get_intersections([head = {x, y} | rest], map, acc) do
    neighbors = [head, {x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    is_intersection = Enum.all?(neighbors, &is_scaffold?(map, &1))
    new_acc = if is_intersection, do: [head | acc], else: acc
    get_intersections(rest, map, new_acc)
  end

  defp is_scaffold?(map, loc), do: Map.has_key?(map, loc)

  defp build_map(path) do
    {:ok, _pid} = Agent.start_link(fn -> %Bot{loc: {0, 0}} end, name: __MODULE__)
    code = Intcode.load(path)
    Intcode.run(code, [], nil, &camera/1)
    result = Agent.get(__MODULE__, fn state -> state end)
    Agent.stop(__MODULE__)
    result
  end

  defp camera(i) do
    {map, loc, bot, dir} = Agent.get(__MODULE__, fn state -> {state.map, state.loc, state.bot, state.dir} end)
    {new_map, new_loc, new_bot, new_dir} = update_state(i, map, loc, bot, dir)
    Agent.update(__MODULE__, fn state -> %Bot{state | map: new_map, loc: new_loc, bot: new_bot, dir: new_dir} end)
  end

  def update_state(i, map, loc = {x, y}, bot, dir) do
    cond do
      i in [?^, ?<, ?v, ?>, ?X] ->
        {Map.put(map, loc, :bot), {x + 1, y}, {x, y}, i}

      i == ?# ->
        {Map.put(map, loc, :scaffold), {x + 1, y}, bot, dir}

      i == ?. ->
        {map, {x + 1, y}, bot, dir}

      i == ?\n ->
        {map, {0, y + 1}, bot, dir}

      true ->
        IO.puts("HUH? #{inspect(i)}")
        {map, loc, bot, dir}
    end
  end
end
