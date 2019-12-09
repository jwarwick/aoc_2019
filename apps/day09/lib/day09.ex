defmodule Day09 do
  @moduledoc """
  AoC 2019, Day 9 - Sensor Boost
  """

  @doc """
  Run self-test and generate BOOST keycode
  """
  def part1(), do: boost(1)

  @doc """
  Get coordinates of distress signal
  """
  def part2(), do: boost(2)

  defp boost(arg) do
    s = self()
    Util.priv_file(:day09, "day9_input.txt")
    |> Intcode.load()
    |> Intcode.run([arg], nil, fn x -> send(s, {:output, x}) end)
    receive do
      {:output, num} -> num
    after
      10_000 -> :timeout
    end
  end
end
