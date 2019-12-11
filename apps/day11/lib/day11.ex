defmodule Day11 do
  @moduledoc """
  AoC 2019, Day 11 - Space Police
  """

  @doc """
  Run the Intcode program to paint the hull
  Count the number of unique square painted 
  """
  def part1 do
    Util.priv_file(:day11, "day11_input.txt")
    |> Robot.paint()
    |> Map.keys()
    |> Enum.count()
  end
end
