defmodule Game do
  @moduledoc """
  Intcode Arcade Cabinet
  """

  defstruct tiles: %{}, output: []

  def print(map) do
    pts = Map.keys(map)

    {min_x, max_x} = Enum.map(pts, fn {x, _y} -> x end) |> Enum.min_max()
    {min_y, max_y} = Enum.map(pts, fn {_x, y} -> y end) |> Enum.min_max()

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        print_char(Map.get(map, {x,y}, :empty))
      end
      IO.write("\n")
    end
    :ok
  end

  defp print_char(:empty), do: IO.write(" ")
  defp print_char(:wall), do: IO.write("=")
  defp print_char(:block), do: IO.write("#")
  defp print_char(:paddle), do: IO.write("_")
  defp print_char(:ball), do: IO.write("*")

  @doc """
  Run the arcade game
  """
  def play(str, tiles \\ %{}) do
    {:ok, _pid} = Agent.start_link(fn -> %Game{tiles: tiles} end, name: __MODULE__)
    code = Intcode.load(str)
    Intcode.run(code, [], nil, &output/1)
    tiles = Agent.get(__MODULE__, fn state -> state.tiles end)
    Agent.stop(__MODULE__)
    tiles
  end

  def output(cmd) do
    output(cmd, Agent.get(__MODULE__, fn state -> state.output end))
  end

  def output(cmd, curr_output) when length(curr_output) < 2 do
    Agent.update(__MODULE__, fn state -> %Game{state | output: [cmd | curr_output]} end)
  end

  def output(cmd, curr_output) do
    [x, y, type] = [cmd | curr_output] |> Enum.reverse()
    kind = tile(type)
    tiles = Agent.get(__MODULE__, fn state -> state.tiles end)
    tiles = Map.put(tiles, {x, y}, kind)
    Agent.update(__MODULE__, fn state -> %Game{state | tiles: tiles, output: []} end)
  end

  defp tile(0), do: :empty
  defp tile(1), do: :wall
  defp tile(2), do: :block
  defp tile(3), do: :paddle
  defp tile(4), do: :ball

end
