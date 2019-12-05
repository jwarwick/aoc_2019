defmodule Day05 do
  @moduledoc """
  AoC 2019, Day 5 - Intcode Thermal Environment Supervision Terminal
  """

  @doc """
  Compute diagnostic code generated from TEST
  """
  def part1, do: run(1)

  @doc """
  Compute the thermal radiator TEST output
  """
  def part2, do: run(5)

  defp run(input) do
    Util.priv_file(:day05, "day5_input.txt")
    |> Intcode.load()
    |> Intcode.run([input])

    :ok
  end
end
