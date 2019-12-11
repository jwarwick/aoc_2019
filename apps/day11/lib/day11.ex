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

  @doc """
  Run the Intcode program to paint the hull
  Start on a white panel, get the 8 letter registration
  """
  def part2 do
    Util.priv_file(:day11, "day11_input.txt")
    |> Robot.paint(%{{0, 0} => 1})
    |> Robot.print()
  end
end
