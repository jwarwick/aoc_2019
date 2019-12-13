defmodule Day13 do
  @moduledoc """
  AoC 2019, Day 13 - Care Package
  """

  @doc """
  Run the Intcode program to start the game
  Count the number of block tiles on the screen
  """
  def part1 do
    Util.priv_file(:day13, "day13_input.txt")
    |> Game.play()
    |> Map.values()
    |> Enum.filter(fn x -> x == :block end)
    |> Enum.count()
  end

end
