defmodule Day01 do
  @moduledoc """
  AoC 2019, Day 1
  """

  @doc """
  Compute required fuel for Part 1
  """
  def part1 do
    Application.app_dir(:day01, "priv")
    |> Path.join("day1_input.txt")
    |> Util.split_file_to_ints()
    |> Enum.map(&required_fuel/1)
    |> Enum.sum()
  end

  @doc """
  Compute fuel required for a single module
  """
  def required_fuel(mass) do
    Integer.floor_div(mass, 3) - 2
  end

end
