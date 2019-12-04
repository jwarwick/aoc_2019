defmodule Day04 do
  @moduledoc """
  Aoc 2019, Day 4 - Secure Container
  """

  @first 134_564
  @last 585_159

  @doc """
  Count the number of valid password possibilities
  """
  def part1 do
    Enum.to_list(@first..@last)
    |> Enum.filter(&valid?/1)
    |> Enum.count()
  end

  @doc """
  Count the number of valid password possibilities
  """
  def part2 do
    Enum.to_list(@first..@last)
    |> Enum.filter(&valid?/1)
    |> Enum.filter(&standalone_repeat?/1)
    |> Enum.count()
  end

  @doc """
  Is the input password monotonic and containg at least one duplicate pair of numbers
  """
  def valid?(pass), do: monotonic?(pass) && has_repeat?(pass)

  @doc """
  Is the password monotonic
  """
  def monotonic?(password) do
    digits = Integer.digits(password)
    digits == Enum.sort(digits)
  end

  @doc """
  Does the password contain a repeated number
  """
  def has_repeat?(password) do
    Integer.digits(password)
    |> Enum.chunk_by(& &1)
    |> Enum.any?(&(Enum.count(&1) >= 2))
  end

  @doc """
  Does the password have repeated digits that are not part of a longer run of that digit
  """
  def standalone_repeat?(password) do
    Integer.digits(password)
    |> Enum.chunk_by(& &1)
    |> Enum.any?(&(2 == Enum.count(&1)))
  end
end
