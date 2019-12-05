defmodule Day05 do
  @moduledoc """
  AoC 2019, Day 5 - Intcode Thermal Environment Supervision Terminal
  """

  @doc """
  Compute diagnostic code generated from TEST
  """
  def part1 do
    Util.priv_file(:day05, "day5_input.txt")
    |> Intcode.load()
    |> Intcode.run([1])
    :ok
  end
end
