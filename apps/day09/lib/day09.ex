defmodule Day09 do
  @moduledoc """
  AoC 2019, Day 9 - Sensor Boost
  """

  @doc """
  Run self-test and generate BOOST keycode
  """
  def part1 do
    s = self()
    Util.priv_file(:day09, "day9_input.txt")
    |> Intcode.load()
    |> Intcode.run([1], nil, fn x -> send(s, {:output, x}) end)
    receive do
      {:output, num} -> num
    after
      10_000 -> :timeout
    end
  end
end
