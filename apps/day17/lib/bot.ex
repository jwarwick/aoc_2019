defmodule Bot do
  @moduledoc """
  Intcode Wired Cameras and Vacuum Bot
  """

  defstruct map: %{}, loc: {0, 0}

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

  defp is_scaffold?(map, loc), do: :scaffold == Map.get(map, loc, :not_scaffold)

  defp build_map(path) do
    {:ok, _pid} = Agent.start_link(fn -> %Bot{loc: {0, 0}} end, name: __MODULE__)
    code = Intcode.load(path)
    Intcode.run(code, [], nil, &camera/1)
    result = Agent.get(__MODULE__, fn state -> state end)
    Agent.stop(__MODULE__)
    result
  end

  defp camera(i) do
    {map, loc} = Agent.get(__MODULE__, fn state -> {state.map, state.loc} end)
    {new_map, new_loc} = update_state(i, map, loc)
    Agent.update(__MODULE__, fn state -> %Bot{state | map: new_map, loc: new_loc} end)
  end

  def update_state(i, map, loc = {x, y}) do
    cond do
      i in [?#, ?^, ?<, ?v, ?>] ->
        {Map.put(map, loc, :scaffold), {x + 1, y}}

      i == ?. ->
        {map, {x + 1, y}}

      i == ?\n ->
        {map, {0, y + 1}}

      true ->
        IO.puts("HUH? #{inspect(i)}")
        {map, loc}
    end
  end
end
