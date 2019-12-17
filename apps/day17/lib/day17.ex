defmodule Day17 do
  @moduledoc """
  AoC 2019, Day 17 - Set and Forget
  """

  @doc """
  """
  def part1 do
    Util.priv_file(:day17, "day17_input.txt")
    |> Bot.alignment()
  end
end
