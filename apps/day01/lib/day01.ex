defmodule Day01 do
  @moduledoc """
  AoC 2019, Day 1
  """

  @doc """
  Compute required fuel for Part 1
  """
  def part1 do
    total(&required_fuel/1)
  end

  @doc """
  Compute required fuel for Part 2
  """
  def part2 do
    total(&summed_fuel/1)
  end

  @doc """
  Sum required fuel for all modules, using the specified function
  """
  def total(func) do
    Util.priv_file(:day01, "day1_input.txt")
    |> Util.split_file_to_ints()
    |> Enum.map(func)
    |> Enum.sum()
  end

  @doc """
  Compute fuel required for a single module, taking into account the weight of the needed fuel
  """
  def summed_fuel(mass) do
    fuel = required_fuel(mass)
    summed_fuel_acc(required_fuel(fuel), fuel)
  end

  defp summed_fuel_acc(extra, total) when extra <= 0, do: total

  defp summed_fuel_acc(extra, total) do
    summed_fuel_acc(required_fuel(extra), total + extra)
  end

  @doc """
  Compute fuel required for a single module
  """
  def required_fuel(mass) do
    Integer.floor_div(mass, 3) - 2
  end
end
