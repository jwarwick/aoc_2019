defmodule Day17 do
  @moduledoc """
  AoC 2019, Day 17 - Set and Forget
  """

  @doc """
  Compute the alignment parameters
  """
  def part1 do
    Util.priv_file(:day17, "day17_input.txt")
    |> Bot.alignment()
  end

  @doc """
  Compute the dust collected while notify the robots
  """
  def part2 do
    Util.priv_file(:day17, "day17_input.txt")
    |> Bot.tour()
  end
end
