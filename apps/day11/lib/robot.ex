defmodule Robot do
  @moduledoc """
  Emergency Hull Painting Robot
  """

  defstruct heading: :up, position: {0, 0}, panels: %{}, next_input: :paint

  @black 0
  @white 1

  @left  0
  @right 1

  def print(map) do
    pts = Map.keys(map)

    {min_x, max_x} = Enum.map(pts, fn {x, _y} -> x end) |> Enum.min_max()
    {min_y, max_y} = Enum.map(pts, fn {_x, y} -> y end) |> Enum.min_max()

    for y <- max_y..min_y do
      for x <- min_x..max_x do
        print_char(Map.get(map, {x,y}, @black))
      end
      IO.write("\n")
    end
    :ok
  end

  defp print_char(@black), do: IO.write(".")
  defp print_char(@white), do: IO.write("#")

  @doc """
  Use an Intcode program to cause the robot to paint
  """
  def paint(str, panels \\ %{}) do
    {:ok, _pid} = Agent.start_link(fn -> %Robot{panels: panels} end, name: __MODULE__)
    code = Intcode.load(str)
    Intcode.run(code, [], &camera/0, &action/1)
    panels = Agent.get(__MODULE__, fn state -> state.panels end)
    Agent.stop(__MODULE__)
    panels
  end

  def camera do
    color = Agent.get(__MODULE__, fn state -> Map.get(state.panels, state.position, @black) end)
    color
  end

  def action(cmd) do
    action(cmd, Agent.get(__MODULE__, fn state -> state.next_input end))
  end

  def action(cmd, :paint) do
    {panels, pos} = Agent.get(__MODULE__, fn state -> {state.panels, state.position} end)
    panels = Map.put(panels, pos, cmd)
    Agent.update(__MODULE__, fn state -> %Robot{state | panels: panels, next_input: :move} end)
  end

  def action(cmd, :move) do
    {pos, heading} = Agent.get(__MODULE__, fn state -> {state.position, state.heading} end)
    heading = update_heading(heading, cmd)
    pos = update_position(pos, heading)
    Agent.update(__MODULE__, fn state -> %Robot{state | position: pos, heading: heading, next_input: :paint} end)
  end

  defp update_heading(:up, @left), do: :left
  defp update_heading(:left, @left), do: :down
  defp update_heading(:down, @left), do: :right
  defp update_heading(:right, @left), do: :up

  defp update_heading(:up, @right), do: :right
  defp update_heading(:right, @right), do: :down
  defp update_heading(:down, @right), do: :left
  defp update_heading(:left, @right), do: :up

  defp update_position({x, y}, :up), do: {x, y+1}
  defp update_position({x, y}, :down), do: {x, y-1}
  defp update_position({x, y}, :left), do: {x-1, y}
  defp update_position({x, y}, :right), do: {x+1, y}
end
