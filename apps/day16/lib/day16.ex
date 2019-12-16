defmodule Day16 do
  @moduledoc """
  AoC 2019, Day 16 - Flawed Frequency Transmission
  """

  @doc """
  After 100 phases of FFT, what are the first eight digits in the final output list?
  """
  def part1 do
    Util.priv_file(:day16, "day16_input.txt")
    |> File.read!()
    |> String.trim()
    |> fft(100)
    |> String.slice(0..7)
  end

  def part2 do
    Util.priv_file(:day16, "day16_input.txt")
    |> File.read!()
    |> String.trim()
    |> decode()
  end

  @doc """
  Compute the FFT of the given string for phase_cnt cycles
  """
  def fft(str, phase_cnt) do
    digits =
      String.graphemes(str)
      |> Enum.map(&String.to_integer/1)

    phase(digits, phase_cnt)
  end

  @doc """
  Decode a message
  """
  def decode(str, phase_cnt \\ 100) do
    skip = String.slice(str, 0, 7)
           |> String.to_integer()

    String.graphemes(str)
    |> List.duplicate(10_000)
    |> List.flatten()
    |> Enum.drop(skip)
    |> Enum.map(&String.to_integer/1)
    |> Enum.take(skip)
    |> do_phases(phase_cnt)
    |> Enum.take(8)
    |> Enum.join()
  end


  def do_phases(lst, 0), do: lst
  def do_phases(add, phase_cnt) do
    do_phases(reverse_sum(add), phase_cnt - 1)
  end

  def reverse_sum(lst) do
    rolling_sum(Enum.reverse(lst), 0, [])
  end

  def rolling_sum([], _sum, acc), do: acc
  def rolling_sum([head | rest], sum, acc) do
    new = sum + head
    d = Integer.digits(new)
        |> Enum.take(-1)
        |> hd()
    rolling_sum(rest, new, [d | acc])
  end

  @base_pattern [0, 1, 0, -1]
  def pattern(digit) do
    Stream.flat_map(@base_pattern, &make_dups(&1, digit + 1))
    |> Stream.cycle()
    |> Stream.drop(1)
  end
  
  defp make_dups(val, cnt) do
    List.duplicate(val, cnt)
  end

  def phase(digits, 0) do
    Enum.join(digits)
  end

  def phase(digits, cnt) do
    Enum.with_index(digits)
    |> Enum.map(fn {_val, idx} -> output_element(idx, digits) end)
    |> phase(cnt - 1)
  end

  def output_element(idx, digits) do
    p = pattern(idx)

    Enum.zip(digits, p)
    |> Enum.map(fn {d, p} -> d * p end)
    |> Enum.sum()
    |> abs()
    |> Integer.digits()
    |> Enum.take(-1)
    |> hd()
  end
end
