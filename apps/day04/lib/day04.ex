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
  Is the input password monotonic and containg at least one duplicate pair of numbers
  """
  def valid?(pass), do: monotonic?(pass) && has_repeat?(pass)

  @doc """
  Is the password monotonic
  """
  def monotonic?(password), do: monotonic?(-1, Integer.digits(password))

  defp monotonic?(_last, []), do: true
  defp monotonic?(last, [head | tail]) when head >= last, do: monotonic?(head, tail)
  defp monotonic?(_last, _list), do: false

  @doc """
  Does the password contain a repeated number
  """
  def has_repeat?(password) do
    digits = [_head | tail] = Integer.digits(password)

    Enum.zip(digits, tail)
    |> match?()
  end

  defp match?([]), do: false
  defp match?([{x, x} | _tail]), do: true
  defp match?([_head | tail]), do: match?(tail)
end
