defmodule Game do
  @moduledoc """
  Intcode Arcade Cabinet
  """

  defstruct tiles: %{}, score: 0, output: [], window: nil

  def print({map, score}) do
    pts = Map.keys(map)

    {min_x, max_x} = Enum.map(pts, fn {x, _y} -> x end) |> Enum.min_max()
    {min_y, max_y} = Enum.map(pts, fn {_x, y} -> y end) |> Enum.min_max()

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        IO.write(print_char(Map.get(map, {x,y}, :empty)))
      end
      IO.write("\n")
    end
    IO.puts "SCORE: #{score}"
    :ok
  end

  defp print_char(:empty), do: " "
  defp print_char(:wall), do: "="
  defp print_char(:block), do: "#"
  defp print_char(:paddle), do: "_"
  defp print_char(:ball), do: "*"

  def render({map, score}) do
    ExNcurses.clear()
    pts = Map.keys(map)

    {min_x, max_x} = Enum.map(pts, fn {x, _y} -> x end) |> Enum.min_max()
    {min_y, max_y} = Enum.map(pts, fn {_x, y} -> y end) |> Enum.min_max()

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        ExNcurses.mvaddstr(y, x, print_char(Map.get(map, {x,y}, :empty)))
      end
    end
    ExNcurses.mvaddstr(max_y + 5, 0, "Score: #{score}")
    ExNcurses.refresh()
  end

  @doc """
  Run the arcade game
  """
  def play(str, quarters \\ 1)do
    ExNcurses.initscr()
    win = ExNcurses.newwin(100, 100, 1, 0)
    {:ok, _pid} = Agent.start_link(fn -> %Game{window: win} end, name: __MODULE__)
    code = Intcode.load(str) |> Intcode.poke(0, quarters)
    Intcode.run(code, [], &input/0, &output/1)
    result = Agent.get(__MODULE__, fn state -> {state.tiles, state.score} end)
    Agent.stop(__MODULE__)
    ExNcurses.endwin()
    result
  end

  def input do
    state = Agent.get(__MODULE__, fn state -> {state.tiles, state.score} end)
    render(state) 
    {bx, _by} = find_item(:ball)
    {px, _py} = find_item(:paddle)
    bx - px
  end

  def find_item(item) do
    Agent.get(__MODULE__, fn state -> state.tiles end)
    |> Enum.find(fn {_k, v} -> v == item end)
    |> elem(0)
  end

  def output(cmd) do
    output(cmd, Agent.get(__MODULE__, fn state -> state.output end))
  end

  def output(cmd, curr_output) when length(curr_output) < 2 do
    Agent.update(__MODULE__, fn state -> %Game{state | output: [cmd | curr_output]} end)
  end

  def output(cmd, curr_output) do
    [x, y, type] = [cmd | curr_output] |> Enum.reverse()
    output(x, y, type)
  end

  def output(-1, 0, score) do
    Agent.update(__MODULE__, fn state -> %Game{state | score: score, output: []} end)
  end

  def output(x, y, type) do
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
