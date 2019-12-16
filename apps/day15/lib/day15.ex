defmodule Day15 do
  @moduledoc """
  AoC 2019, Day 5 - Oxygen System
  """

  @doc """
  Return the fewest number of movement commands to reach the oxygen system
  """
  def part1 do
    Util.priv_file(:day15, "day15_input.txt")
    |> Droid.explore(10_000)
  end

  @doc """
  Find how many minutes are required to replenish the oxygen
  """
  def part2 do
    Util.priv_file(:day15, "day15_input.txt")
    |> Droid.replenish(1_000_000)
  end
end
