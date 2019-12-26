defmodule Day25 do
  @moduledoc """
  AoC 2019, Day 25 - Cryostasis
  """
  @path """
  west
  take semiconductor
  west
  take planetoid
  west
  take food ration
  west
  take fixed point
  west
  east
  south
  west
  east
  north
  east
  east
  south
  south
  south
  north
  north
  east
  east
  north
  east
  north
  """

  @doc """
  Find the password to the main airlock
  """
  def part1 do
    {:ok, _pid} = Agent.start_link(fn -> [] end, name: __MODULE__)
    Util.priv_file(:day25, "day25_input.txt")
    |> Intcode.load()
    |> Intcode.run(String.to_charlist(@path), &input/0, &output/1)
    Agent.stop(__MODULE__)
    :ok
  end

  def output(c), do: IO.write(<<c>>)

  def input() do
    input(Agent.get_and_update(__MODULE__, &get_update/1))
  end

  def get_update([]), do: {nil, []}
  def get_update([head | rest]), do: {head, rest}

  def input(nil) do
    val = IO.gets("> ")
    [h | rest] = String.to_charlist(val)
    Agent.update(__MODULE__, fn _state -> rest end)
    h
  end

  def input(val), do: val
end
